import puppeteer from "puppeteer";
import mongoose from "mongoose";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import Category from "../models/Category.model.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load .env ở cấp gốc dự án
dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const MONGODB_URI = process.env.MONGODB_URI;

async function scrape() {
  try {
    if (!MONGODB_URI) {
      throw new Error("❌ Missing MONGODB_URI in .env file");
    }

    await mongoose.connect(MONGODB_URI);
    console.log("✅ Connected to MongoDB");

    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();

    await page.goto("https://nhathuoclongchau.com.vn", {
      waitUntil: "networkidle2",
      timeout: 60000, // tránh timeout sớm
    });

    // 🧠 Scrape danh mục "Danh mục nổi bật"
    const categories = await page.evaluate(() => {
      const results = [];
      const h2 = Array.from(document.querySelectorAll("h2")).find((el) =>
        el.textContent.toLowerCase().includes("danh mục nổi bật")
      );

      if (!h2) return results;

      const gridContainer = h2.parentElement?.nextElementSibling;
      if (!gridContainer) return results;

      gridContainer.querySelectorAll("a").forEach((el) => {
        const name = el.querySelector("h3")?.innerText?.trim();
        const url = el.href;
        if (name && url) results.push({ name, url });
      });

      return results;
    });

    console.log("📦 Found categories:", categories.length);
    console.log(categories);

    if (!categories.length) {
      console.warn("⚠️ No categories found — check site structure!");
    }

    // 💾 Lưu MongoDB
    for (const cat of categories) {
      const exists = await Category.findOne({ name: cat.name });
      if (!exists) {
        await Category.create({
          name: cat.name,
          description: `Danh mục: ${cat.name}`,
          url: cat.url,
        });
        console.log(`✅ Saved category: ${cat.name}`);
      } else {
        console.log(`⚠️ Skipped (already exists): ${cat.name}`);
      }
    }

    // 🧩 Test scrape sản phẩm ở danh mục đầu tiên
    if (categories.length > 0) {
      const firstCategory = categories[0];
      console.log(`🔍 Scraping first category: ${firstCategory.name}`);

      await page.goto(firstCategory.url, { waitUntil: "networkidle2", timeout: 60000 });

      const products = await page.evaluate(() => {
        const list = [];
        document.querySelectorAll("a.product-item").forEach((el) => {
          const name = el.querySelector("h3")?.innerText?.trim();
          const price = el.querySelector(".product-price")?.innerText?.trim();
          const link = el.href;
          if (name && link) list.push({ name, price, link });
        });
        return list;
      });

      console.log(`📦 Found ${products.length} products in ${firstCategory.name}`);
      console.log(products.slice(0, 5)); // chỉ log 5 sản phẩm đầu
    }

    await browser.close();
    await mongoose.disconnect();
    console.log("🎉 Done importing categories!");
  } catch (err) {
    console.error("❌ Error:", err);
    await mongoose.disconnect();
    process.exit(1);
  }
}

scrape();



