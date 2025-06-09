import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_card.dart';
import '../../services/language_service.dart';
import '../auth/login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Function(String)? onLanguageSelected;

  const LanguageSelectionScreen({super.key, this.onLanguageSelected});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = AppConstants.defaultLanguage;

  Future<void> _saveLanguage() async {
    await LanguageService.setLanguageCode(_selectedLanguage);
    
    if (widget.onLanguageSelected != null) {
      widget.onLanguageSelected!(_selectedLanguage);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildLanguageOptions(),
              const Spacer(),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName,
          style: AppTheme.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'uc5b8uc5b4ub97c uc120ud0ddud574uc8fcuc138uc694',
          style: AppTheme.body1.copyWith(
            color: AppTheme.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOptions() {
    return Column(
      children: [
        _buildLanguageCard('ko', 'ud55cuad6duc5b4'),
        _buildLanguageCard('en', 'English'),
        _buildLanguageCard('zh', 'u4e2du6587'),
      ],
    );
  }

  Widget _buildLanguageCard(String languageCode, String languageName) {
    final isSelected = _selectedLanguage == languageCode;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      backgroundColor: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.white,
      borderColor: isSelected ? AppTheme.primaryBlue : null,
      onTap: () {
        setState(() {
          _selectedLanguage = languageCode;
        });
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? Icons.check : Icons.language,
              color: isSelected ? Colors.white : AppTheme.grey,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            languageName,
            style: AppTheme.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveLanguage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'uacc4uc18dud558uae30',
          style: AppTheme.button.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
