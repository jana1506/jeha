import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController cardOwnerController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  
  String selectedCardType = 'mastercard';

  @override
  void dispose() {
    cardOwnerController.dispose();
    cardNumberController.dispose();
    expController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return cardOwnerController.text.trim().isNotEmpty &&
        cardNumberController.text.replaceAll(' ', '').length >= 16 &&
        expController.text.length >= 5 &&
        cvvController.text.length >= 3;
  }

  @override
  Widget build(BuildContext context) {
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
          'Add New Card',
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
            // Card Type Selection
            Row(
              children: [
                _buildCardTypeButton('mastercard'),
                const SizedBox(width: 12),
                _buildCardTypeButton('visa'),
                const SizedBox(width: 12),
                _buildCardTypeButton('paypal'),
              ],
            ),
            const SizedBox(height: 40),

            // Card Owner
            _buildInputField(
              label: 'Card Owner',
              controller: cardOwnerController,
              hintText: 'Enter card owner name',
            ),
            const SizedBox(height: 24),

            // Card Number
            _buildInputField(
              label: 'Card Number',
              controller: cardNumberController,
              hintText: '0000 0000 0000 0000',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberInputFormatter(),
              ],
            ),
            const SizedBox(height: 24),

            // EXP and CVV Row
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'EXP',
                    controller: expController,
                    hintText: 'MM/YY',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _ExpiryDateInputFormatter(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildInputField(
                    label: 'CVV',
                    controller: cvvController,
                    hintText: 'CVV',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
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
            onPressed: _isFormValid()
                ? () {
                    // Create card data
                    final cardData = {
                      'type': selectedCardType,
                      'color': _getCardGradient(selectedCardType),
                      'number': cardNumberController.text,
                      'owner': cardOwnerController.text,
                      'expiry': expController.text,
                      'cvv': cvvController.text,
                    };
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Card added successfully!'),
                        backgroundColor: Color(0xFF34C759),
                      ),
                    );
                    // Return card data to payment screen
                    Navigator.pop(context, cardData);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9775FA),
              disabledBackgroundColor: const Color(0xFFE7EAEF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Add Card',
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

  LinearGradient _getCardGradient(String type) {
    switch (type) {
      case 'mastercard':
        return const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'visa':
        return const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'paypal':
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF757575), Color(0xFF424242)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Widget _buildCardTypeButton(String type) {
    final isSelected = selectedCardType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedCardType = type),
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF9775FA) : const Color(0xFFE7EAEF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: _getCardIcon(type),
        ),
      ),
    );
  }

  Widget _getCardIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'mastercard':
        icon = Icons.credit_card;
        color = const Color(0xFFEB001B);
        break;
      case 'visa':
        icon = Icons.credit_card;
        color = const Color(0xFF1A1F71);
        break;
      case 'paypal':
        icon = Icons.paypal;
        color = const Color(0xFF003087);
        break;
      default:
        icon = Icons.credit_card;
        color = Colors.grey;
    }
    
    return Icon(icon, color: color, size: 32);
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
          onChanged: (value) => setState(() {}), // Rebuild to enable/disable button
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

// Card Number Formatter (adds space every 4 digits)
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Expiry Date Formatter (adds / after 2 digits)
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length && i < 4; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    
    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}