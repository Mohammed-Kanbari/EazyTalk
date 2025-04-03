import 'package:eazytalk/widgets/buttons/primary_button.dart';
import 'package:eazytalk/widgets/common/modal_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/services/auth/password_validation_service.dart';
import 'package:eazytalk/services/auth/password_update_service.dart';
import 'package:eazytalk/widgets/auth/password_input_field.dart';
import 'package:eazytalk/widgets/auth/password_requirement_row.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({super.key});

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final PasswordUpdateService _passwordService = PasswordUpdateService();

  bool _isLoading = false;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasCapitalLetter = false;
  bool _hasNumber = false;
  bool _doPasswordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate passwords whenever they change
  void _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _hasMinLength = PasswordValidationService.hasMinLength(password);
      _hasCapitalLetter = PasswordValidationService.hasCapitalLetter(password);
      _hasNumber = PasswordValidationService.hasNumber(password);
      _doPasswordsMatch =
          PasswordValidationService.doPasswordsMatch(password, confirmPassword);
    });
  }

  // Check if password meets all criteria
  bool get _isPasswordValid =>
      PasswordValidationService.isPasswordValid(_passwordController.text);

  // Method to update password
  Future<void> _updatePassword() async {
    // First validate all fields
    if (!_isPasswordValid || !_doPasswordsMatch) {
      PasswordUpdateService.showResultSnackBar(
          context, false, AppLocalizations.of(context).translate('password_too_weak'));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _passwordService.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _passwordController.text,
      );

      if (mounted) {
        PasswordUpdateService.showResultSnackBar(
            context, result['success'], result['message']);

        if (result['success']) {
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    ModalHeader(
                      title: l10n.translate('reset_password'),
                      onClose: () => Navigator.pop(context),
                    ),
                    SizedBox(height: 30.h),

                    // Main content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title section with icon
                        _buildTitleSection(),

                        SizedBox(height: 12.h),

                        // Instructions box
                        _buildInstructionsBox(isDarkMode),

                        SizedBox(height: 24.h),

                        // Current Password Field
                        PasswordInputField(
                          controller: _currentPasswordController,
                          label: l10n.translate('current_password'),
                          hintText: l10n.translate('enter_current'),
                          onVisibilityChanged: (_) {},
                          isDarkMode: isDarkMode,
                        ),

                        SizedBox(height: 24.h),

                        // New Password Field
                        PasswordInputField(
                          controller: _passwordController,
                          label: l10n.translate('new_password'),
                          hintText: l10n.translate('enter_new'),
                          showValidationIcon: true,
                          isValid: _isPasswordValid,
                          onVisibilityChanged: (_) {},
                          isDarkMode: isDarkMode,
                        ),

                        // Password requirements checklist
                        if (_passwordController.text.isNotEmpty)
                          _buildPasswordRequirements(),

                        SizedBox(height: 24.h),

                        // Confirm Password Field
                        PasswordInputField(
                          controller: _confirmPasswordController,
                          label: l10n.translate('confirm_password'),
                          hintText: l10n.translate('confirm_new'),
                          showValidationIcon: true,
                          isValid: _doPasswordsMatch,
                          onVisibilityChanged: (_) {},
                          isDarkMode: isDarkMode,
                        ),

                        // Password match hint
                        if (_confirmPasswordController.text.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h, left: 4.w),
                            child: PasswordRequirementRow(
                              isMet: _doPasswordsMatch,
                              text: l10n.translate('passwords_match'),
                            ),
                          ),

                        // Add spacing before button
                        SizedBox(height: 80.h),

                        // Reset Button
                        _buildResetButton(),

                        // Extra space at bottom
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // Title section with icon
  Widget _buildTitleSection() {
    final textColor = AppColors.getTextPrimaryColor(context);
    final l10n = AppLocalizations.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.lock_outline,
          size: 24.sp,
          color: AppColors.primary,
        ),
        SizedBox(width: 8.w),
        Text(
          l10n.translate('enter_new_pass'),
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // Instructions box
  Widget _buildInstructionsBox(bool isDarkMode) {
    final backgroundColor = isDarkMode
        ? const Color(0xFF0A3A42) // Dark blue-gray for dark theme
        : const Color(0xFFE8F8FC); // Light blue for light theme
        
    final borderColor = isDarkMode
        ? const Color(0xFF085F6B) // Darker blue-gray for border
        : const Color(0xFFCCEEF5); // Light blue for border
    
    final textColor = isDarkMode
        ? Colors.grey[300]
        : Colors.grey[700];
    
    final l10n = AppLocalizations.of(context);
    
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10n.translate('password_note'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Password requirements list
  Widget _buildPasswordRequirements() {
    final l10n = AppLocalizations.of(context);
    
    return Padding(
      padding: EdgeInsets.only(top: 12.h, left: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasswordRequirementRow(
            isMet: _hasMinLength,
            text: l10n.translate('at_least_6'),
          ),
          SizedBox(height: 4.h),
          PasswordRequirementRow(
            isMet: _hasCapitalLetter,
            text: l10n.translate('capital_letter'),
          ),
          SizedBox(height: 4.h),
          PasswordRequirementRow(
            isMet: _hasNumber,
            text: l10n.translate('one_number'),
          ),
        ],
      ),
    );
  }

  // Reset button
  Widget _buildResetButton() {
    final l10n = AppLocalizations.of(context);
    final bool canReset = !_isLoading &&
        _isPasswordValid &&
        _doPasswordsMatch &&
        _currentPasswordController.text.isNotEmpty;

    return PrimaryButton(
      text: l10n.translate('reset'),
      onPressed: canReset ? _updatePassword : null,
      isLoading: _isLoading,
    );
  }
}