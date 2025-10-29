import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/pharmacist_service.dart';

class ProductManagementPage extends ConsumerStatefulWidget {
  const ProductManagementPage({super.key});

  @override
  ConsumerState<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends ConsumerState<ProductManagementPage> {
  List<dynamic> products = [];
  List<dynamic> categories = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load categories
      final categoriesResult = await PharmacistService.getCategories();
      if (categoriesResult['success'] == true) {
        setState(() {
          categories = categoriesResult['data']['docs'] ?? [];
        });
      }

      // Load products
      await _loadProducts();
    } catch (e) {
      setState(() {
        error = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final result = await PharmacistService.getProducts(
        category: selectedCategory,
        search: searchQuery.isNotEmpty ? searchQuery : null,
      );
      
      if (result['success'] == true) {
        setState(() {
          products = result['data']['docs'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Lỗi khi tải sản phẩm';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi khi tải sản phẩm: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                    _loadProducts();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedCategory,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Tất cả danh mục'),
                    ),
                    ...categories.map((category) => DropdownMenuItem<String>(
                      value: category['_id'],
                      child: Text(category['name']),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                    _loadProducts();
                  },
                ),
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              error!,
                              style: TextStyle(color: Colors.red[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : products.isEmpty
                        ? const Center(
                            child: Text(
                              'Không có sản phẩm nào',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductCard(product);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final inStock = product['inStock'] ?? 0;
    final isLowStock = inStock <= 10;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isLowStock ? Colors.orange[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLowStock ? Colors.orange[300] : Colors.blue[300],
          child: Icon(
            Icons.medication,
            color: isLowStock ? Colors.orange[700] : Colors.blue[700],
          ),
        ),
        title: Text(
          product['name'] ?? 'Không có tên',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Giá: ${product['price']?.toString() ?? 'N/A'} VNĐ'),
            Text('Danh mục: ${product['category']?['name'] ?? 'N/A'}'),
            Text(
              'Tồn kho: $inStock',
              style: TextStyle(
                color: isLowStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditProductDialog(product);
                break;
              case 'inventory':
                _showInventoryDialog(product);
                break;
              case 'delete':
                _showDeleteConfirmDialog(product);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'inventory',
              child: Row(
                children: [
                  Icon(Icons.inventory),
                  SizedBox(width: 8),
                  Text('Cập nhật tồn kho'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        categories: categories,
        onSave: (productData) async {
          final result = await PharmacistService.createProduct(productData);
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm sản phẩm thành công')),
            );
            _loadProducts();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Lỗi khi thêm sản phẩm')),
            );
          }
        },
      ),
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => _ProductDialog(
        categories: categories,
        product: product,
        onSave: (productData) async {
          final result = await PharmacistService.updateProduct(product['_id'], productData);
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật sản phẩm thành công')),
            );
            _loadProducts();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Lỗi khi cập nhật sản phẩm')),
            );
          }
        },
      ),
    );
  }

  void _showInventoryDialog(Map<String, dynamic> product) {
    final priceController = TextEditingController(text: product['price']?.toString() ?? '');
    final stockController = TextEditingController(text: product['inStock']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật tồn kho'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Giá (VNĐ)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'Số lượng tồn kho',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await PharmacistService.updateInventory(
                product['_id'],
                {
                  'price': double.tryParse(priceController.text) ?? 0,
                  'inStock': int.tryParse(stockController.text) ?? 0,
                },
              );
              
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật tồn kho thành công')),
                );
                _loadProducts();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Lỗi khi cập nhật tồn kho')),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await PharmacistService.deleteProduct(product['_id']);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa sản phẩm thành công')),
                );
                _loadProducts();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['message'] ?? 'Lỗi khi xóa sản phẩm')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final List<dynamic> categories;
  final Map<String, dynamic>? product;
  final Function(Map<String, dynamic>) onSave;

  const _ProductDialog({
    required this.categories,
    this.product,
    required this.onSave,
  });

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _dosageController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  final _manufacturerController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'] ?? '';
      _descriptionController.text = widget.product!['description'] ?? '';
      _priceController.text = widget.product!['price']?.toString() ?? '';
      _stockController.text = widget.product!['inStock']?.toString() ?? '';
      _dosageController.text = widget.product!['dosage'] ?? '';
      _sideEffectsController.text = widget.product!['sideEffects'] ?? '';
      _manufacturerController.text = widget.product!['manufacturer'] ?? '';
      _selectedCategory = widget.product!['category']?['_id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product != null ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Vui lòng nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Danh mục *',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedCategory,
                items: widget.categories.map((category) => DropdownMenuItem<String>(
                  value: category['_id'],
                  child: Text(category['name']),
                )).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá (VNĐ) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Vui lòng nhập giá';
                  if (double.tryParse(value!) == null) return 'Giá không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Số lượng tồn kho *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Vui lòng nhập số lượng';
                  if (int.tryParse(value!) == null) return 'Số lượng không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Liều lượng',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sideEffectsController,
                decoration: const InputDecoration(
                  labelText: 'Tác dụng phụ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(
                  labelText: 'Nhà sản xuất',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final productData = {
                'name': _nameController.text,
                'description': _descriptionController.text,
                'category': _selectedCategory,
                'price': double.parse(_priceController.text),
                'inStock': int.parse(_stockController.text),
                'dosage': _dosageController.text,
                'sideEffects': _sideEffectsController.text,
                'manufacturer': _manufacturerController.text,
              };
              widget.onSave(productData);
              Navigator.pop(context);
            }
          },
          child: Text(widget.product != null ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
