import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool saveAsPrimary = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  Future<void> _loadExistingAddress() async {
    final addressData = await _dbService.getAddress();
    if (addressData != null && mounted) {
      setState(() {
        nameController.text = addressData['name'] ?? '';
        countryController.text = addressData['country'] ?? '';
        cityController.text = addressData['city'] ?? '';
        phoneController.text = addressData['phone'] ?? '';
        addressController.text = addressData['address'] ?? '';
        saveAsPrimary = addressData['isPrimary'] ?? true;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    countryController.dispose();
    cityController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return nameController.text.trim().isNotEmpty &&
        countryController.text.trim().isNotEmpty &&
        cityController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty;
  }

  Future<void> _saveAddress() async {
    if (_isFormValid()) {
      // Create address data
      final addressData = {
        'name': nameController.text.trim(),
        'country': countryController.text.trim(),
        'city': cityController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'isPrimary': saveAsPrimary,
      };

      // Save to Firebase
      await _dbService.saveAddress(addressData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved successfully!'),
            backgroundColor: Color(0xFF34C759),
            duration: Duration(seconds: 2),
          ),
        );

        // Return the address data back to cart screen
        Navigator.pop(context, addressData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9775FA)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Address',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            _buildInputField(
              label: 'Name',
              controller: nameController,
              hintText: 'Enter your name',
            ),
            const SizedBox(height: 24),

            // Country and City Row
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Country',
                    controller: countryController,
                    hintText: 'Country',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    label: 'City',
                    controller: cityController,
                    hintText: 'City',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Phone Number
            _buildInputField(
              label: 'Phone Number',
              controller: phoneController,
              hintText: '+880 1234-567890',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Address
            _buildInputField(
              label: 'Address',
              controller: addressController,
              hintText: 'Enter your full address',
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Save as Primary Address Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Save as primary address',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: saveAsPrimary,
                  onChanged: (value) => setState(() => saveAsPrimary = value),
                  activeColor: const Color(0xFF34C759),
                  activeTrackColor: const Color(0xFF34C759).withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isFormValid() ? _saveAddress : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9775FA),
              disabledBackgroundColor: const Color(0xFFE7EAEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save Address',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: _isFormValid() ? Colors.white : const Color(0xFF8F959E),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8F959E),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF8F959E),
              fontSize: 15,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE7EAEF)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE7EAEF)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF9775FA), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}