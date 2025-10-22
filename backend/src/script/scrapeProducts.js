import puppeteer from "puppeteer";
import mongoose from "mongoose";
import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";
import Category from "../models/Category.model.js";
import Product from "../models/Product.model.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const MONGODB_URI = process.env.MONGODB_URI;

// Selector cố định cho khối sản phẩm và nút "Xem thêm"
const PRODUCT_BLOCK_SELECTOR = '.grid.grid-cols-2 > div.h-full.relative.flex.flex-col';
const LOAD_MORE_BUTTON_SELECTOR = 'button.mt-3.flex.w-full.items-center.justify-center'; 

// Hàm phụ để trích xuất và lưu dữ liệu cho một trang danh mục
async function scrapeAndSaveCategoryProducts(page, category) {
    console.log(`\n======================================================`);
    console.log(`🔍 Scraping category: ${category.name} from URL: ${category.url}`);
    
    // Tải trang
    try {
        await page.goto(category.url, { waitUntil: "networkidle2", timeout: 60000 });
    } catch (error) {
        console.error(`❌ Failed to navigate to ${category.url}: ${error.message}`);
        return;
    }

    // --- Logic Tải Toàn bộ Sản phẩm (Cuộn và Click) ---
    console.log(`⏳ Starting scroll and click loop to load all products...`);
    let previousHeight = 0;
    const maxIterations = 20; // Giới hạn số lần cuộn/nhấn

    for (let i = 0; i < maxIterations; i++) {
        const currentHeight = await page.evaluate(() => document.body.scrollHeight);
        
        let shouldBreak = false;
        
        // 1. Tìm và click nút "Xem thêm"
        try {
            const loadMoreButton = await page.$(LOAD_MORE_BUTTON_SELECTOR);
            if (loadMoreButton) {
                const isVisible = await page.evaluate(el => {
                    const style = window.getComputedStyle(el);
                    // Kiểm tra hiển thị
                    return style.display !== 'none' && style.visibility !== 'hidden' && style.opacity !== '0';
                }, loadMoreButton);

                if (isVisible) {
                    console.log(`👆 Found "Xem thêm" button at iteration ${i}. Clicking...`);
                    await loadMoreButton.click();
                    await new Promise((r) => setTimeout(r, 2000)); // Chờ load
                    previousHeight = 0; // Đặt lại để đảm bảo cuộn tiếp nếu cần
                    continue; // Tiếp tục vòng lặp
                } else {
                    shouldBreak = true; // Nút tồn tại nhưng bị ẩn -> đã tải hết
                }
            } else {
                 // Nếu không tìm thấy nút sau một lần cuộn/click
                 if (currentHeight === previousHeight) {
                    shouldBreak = true;
                 }
            }
        } catch (e) {
            // Bỏ qua lỗi click hoặc selector
        }
        
        if (shouldBreak) {
            console.log(`📜 Load complete/height stabilized after ${i} iterations.`);
            break;
        }

        // 2. Cuộn xuống nếu chưa ổn định
        previousHeight = currentHeight;
        await page.evaluate(() => window.scrollBy(0, window.innerHeight));
        await new Promise((r) => setTimeout(r, 1000));
    }
    
    // Chờ khối sản phẩm chính xuất hiện lần cuối
    await page.waitForSelector(PRODUCT_BLOCK_SELECTOR, { timeout: 15000 }).catch(() => {
        console.warn(`⚠️ No product blocks found in ${category.name}. Skipping scraping.`);
        return;
    });

    // --- Logic Trích Xuất Dữ Liệu ---
    const products = await page.evaluate((selector, categoryId) => {
        const list = [];
        document.querySelectorAll(selector).forEach((el) => {
            // Tên sản phẩm: h3 với class font-semibold
            const nameElement = el.querySelector("h3.text-body2.font-semibold");
            const name = nameElement ? nameElement.innerText.trim() : null;

            // Link sản phẩm: thẻ <a> đầu tiên
            const url = el.querySelector("a")?.href;

            // URL hình ảnh: thẻ <img> trong thẻ <a> đầu tiên
            const image = el.querySelector("a img")?.src;
            
            // Giá gốc/niêm yết (oldPrice)
            const oldPriceElement = el.querySelector(".text-caption.font-normal.text-gray-6.line-through");
            const oldPriceText = oldPriceElement ? oldPriceElement.innerText.trim() : null;
            
            // Giá mới/giá hiện tại (priceText)
            const priceElement = el.querySelector(".text-blue-5 .font-semibold");
            const priceText = priceElement ? priceElement.innerText.trim() : null;
            
            // Giá tham chiếu (referencePrice) là giá niêm yết (oldPrice) hoặc giá hiện tại
            const priceToSaveText = oldPriceText || priceText; 
            
            const description = name; // Dùng tên làm description nếu không có trường rõ ràng

            if (name && url && image && priceToSaveText) {
                // Xử lý giá tiền: loại bỏ tất cả ký tự không phải số và chuyển thành số nguyên
                const referencePrice = parseInt(priceToSaveText.replace(/[^0-9]/g, ""), 10);
                
                list.push({ 
                    name, 
                    referencePrice, 
                    image, 
                    url,
                    description,
                    categoryId // Truyền ID danh mục vào đây
                });
            }
        });
        return list;
    }, PRODUCT_BLOCK_SELECTOR, category._id.toString()); 

    console.log(`📦 Found ${products.length} valid products in ${category.name}`);

    // --- Logic Lưu MongoDB ---
    let savedCount = 0;
    for (const prod of products) {
        if (!prod.image) {
            console.warn(`⚠️ Skipping ${prod.name}: Image URL is missing.`);
            continue;
        }

        const exists = await Product.findOne({ url: prod.url });
        if (!exists) {
            await Product.create({
                name: prod.name,
                referencePrice: prod.referencePrice, 
                description: prod.description || prod.name,
                category: category._id,
                image: prod.image, 
                url: prod.url,
                // stock: 100, // Thêm nếu cần, loại bỏ nếu không có trong schema
            });
            // console.log(`✅ Saved: ${prod.name}`); // Bỏ comment nếu muốn thấy từng sản phẩm được lưu
            savedCount++;
        }
    }
    console.log(`✅ Saved ${savedCount} new products for category: ${category.name}`);
}

// Hàm chính điều phối việc scraping
async function mainScrapeCoordinator() {
    let browser;
    try {
        if (!MONGODB_URI) throw new Error("❌ Missing MONGODB_URI in .env file");

        await mongoose.connect(MONGODB_URI);
        console.log("✅ Connected to MongoDB");

        // Lấy TẤT CẢ danh mục để lặp qua
        const categories = await Category.find({});
        if (!categories.length) {
            console.log("🤔 No categories found in MongoDB.");
            return;
        }

        browser = await puppeteer.launch({
            headless: true,
            defaultViewport: null,
            args: ["--start-maximized"],
        });

        const page = await browser.newPage();
        
        // Lặp qua từng danh mục và scrape sản phẩm
        for (const category of categories) {
            await scrapeAndSaveCategoryProducts(page, category);
        }

        await browser.close();
        await mongoose.disconnect();
        console.log("\n🎉 Done scraping ALL categories and products!");
    } catch (err) {
        console.error("❌ Fatal Error during scraping process:", err);
        if (browser) await browser.close();
        await mongoose.disconnect();
        process.exit(1);
    }
}

mainScrapeCoordinator();