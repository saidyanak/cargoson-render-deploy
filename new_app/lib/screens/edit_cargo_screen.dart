import 'package:cargo_app/utils/cargo_helper.dart';
import 'package:flutter/material.dart';
import '../services/cargo_service.dart';

class EditCargoScreen extends StatefulWidget {
  final Map<String, dynamic> cargo;

  EditCargoScreen({required this.cargo});

  @override
  _EditCargoScreenState createState() => _EditCargoScreenState();
}

class _EditCargoScreenState extends State<EditCargoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _selfLatController = TextEditingController();
  final _selfLngController = TextEditingController();
  final _targetLatController = TextEditingController();
  final _targetLngController = TextEditingController();
  
  String _selectedSize = 'M';
  bool _isLoading = false;

  final List<String> _sizeOptions = ['S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _loadCargoData();
  }

  // edit_cargo_screen.dart - _loadCargoData method güncellemesi

void _loadCargoData() {
  final cargo = widget.cargo;
  
  // Güvenli field erişimi ile form alanlarını doldur
  _descriptionController.text = CargoHelper.getDescription(cargo);
  _phoneController.text = CargoHelper.getPhoneNumber(cargo);
  
  // Measure bilgilerini güvenli şekilde al
  Map<String, dynamic> measure = CargoHelper.getMeasure(cargo);
  _weightController.text = measure['weight']?.toString() ?? '0';
  _heightController.text = measure['height']?.toString() ?? '0';
  _selectedSize = measure['size'] ?? 'M';
  
  // Konum bilgilerini güvenli şekilde al
  Map<String, dynamic> selfLocation = CargoHelper.getSelfLocation(cargo);
  Map<String, dynamic> targetLocation = CargoHelper.getTargetLocation(cargo);
  
  _selfLatController.text = selfLocation['latitude']?.toString() ?? '0.0';
  _selfLngController.text = selfLocation['longitude']?.toString() ?? '0.0';
  _targetLatController.text = targetLocation['latitude']?.toString() ?? '0.0';
  _targetLngController.text = targetLocation['longitude']?.toString() ?? '0.0';
}

// _updateCargo method güncellemesi
Future<void> _updateCargo() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // Sadece düzenlenebilir kargolar güncellenebilir
  if (!CargoHelper.canEdit(widget.cargo)) {
    _showErrorDialog('Bu kargo artık düzenlenemez. Sadece "Oluşturuldu" durumundaki kargolar düzenlenebilir.');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Kargo ID'sini güvenli şekilde al
    dynamic cargoId = widget.cargo['id'];
    int? id;
    
    if (cargoId is int) {
      id = cargoId;
    } else if (cargoId != null) {
      id = int.tryParse(cargoId.toString());
    }
    
    if (id == null) {
      throw Exception('Geçersiz kargo ID\'si');
    }

    final result = await CargoService.updateCargo(
      cargoId: id,
      description: _descriptionController.text.trim(),
      selfLatitude: double.parse(_selfLatController.text),
      selfLongitude: double.parse(_selfLngController.text),
      targetLatitude: double.parse(_targetLatController.text),
      targetLongitude: double.parse(_targetLngController.text),
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      size: _selectedSize,
      phoneNumber: _phoneController.text.trim(),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kargo başarıyla güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // true ile geri dön (yenileme için)
    } else {
      _showErrorDialog('Kargo güncellenirken bir hata oluştu.');
    }
  } catch (e) {
    _showErrorDialog('Bir hata oluştu: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

// Uyarı kartını da güncelleyelim
Widget _buildWarningCard() {
  final status = CargoHelper.getCargoSituation(widget.cargo);
  final canEdit = CargoHelper.canEdit(widget.cargo);
  
  return Card(
    color: canEdit ? Colors.amber[50] : Colors.red[50],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: canEdit ? Colors.amber[300]! : Colors.red[300]!),
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            canEdit ? Icons.info : Icons.warning,
            color: canEdit ? Colors.amber[800] : Colors.red[800],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canEdit 
                    ? 'Kargo düzenlenebilir durumda.'
                    : 'Bu kargo düzenlenemez!',
                  style: TextStyle(
                    color: canEdit ? Colors.amber[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  canEdit 
                    ? 'Sadece "Oluşturuldu" durumundaki kargolar düzenlenebilir.'
                    : 'Kargo durumu: ${CargoHelper.getStatusDisplayName(status)}. Sadece "Oluşturuldu" durumundaki kargolar düzenlenebilir.',
                  style: TextStyle(
                    color: canEdit ? Colors.amber[800] : Colors.red[800],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kargo Düzenle'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Uyarı kartı
              Card(
                color: Colors.amber[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber[300]!),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber[800]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sadece oluşturulmuş durumundaki kargolar düzenlenebilir.',
                          style: TextStyle(color: Colors.amber[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              
              // Kargo bilgileri kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kargo Bilgileri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Açıklama
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Kargo Açıklaması',
                          hintText: 'Kargonuzun açıklamasını yazın...',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Açıklama boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Telefon
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Telefon Numarası',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Telefon numarası boş bırakılamaz';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Ölçüler kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kargo Ölçüleri',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          // Ağırlık
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Ağırlık (kg)',
                                prefixIcon: Icon(Icons.scale),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ağırlık boş bırakılamaz';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          
                          // Yükseklik
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Yükseklik (cm)',
                                prefixIcon: Icon(Icons.straighten),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Yükseklik boş bırakılamaz';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Boyut seçimi
                      Text(
                        'Kargo Boyutu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedSize,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.aspect_ratio),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: _sizeOptions.map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Text(size),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSize = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Başlangıç konumu kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alınacak Konum',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _selfLatController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                labelText: 'Enlem (Latitude)',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enlem boş bırakılamaz';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _selfLngController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                labelText: 'Boylam (Longitude)',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Boylam boş bırakılamaz';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Hedef konum kartı
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teslim Edilecek Konum',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _targetLatController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                labelText: 'Enlem (Latitude)',
                                prefixIcon: Icon(Icons.flag),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enlem boş bırakılamaz';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _targetLngController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                labelText: 'Boylam (Longitude)',
                                prefixIcon: Icon(Icons.flag),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Boylam boş bırakılamaz';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              // Güncelle butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _updateCargo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 12),
                          Text('Güncelleniyor...'),
                        ],
                      )
                    : Text(
                        'Kargoyu Güncelle',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _selfLatController.dispose();
    _selfLngController.dispose();
    _targetLatController.dispose();
    _targetLngController.dispose();
    super.dispose();
  }
}