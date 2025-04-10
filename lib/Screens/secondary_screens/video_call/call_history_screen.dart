// lib/Screens/secondary_screens/video_call/call_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/models/call_model.dart';
import 'package:eazytalk/services/video_call/call_history_service.dart';
import 'package:eazytalk/services/video_call/call_service.dart';
import 'package:eazytalk/widgets/common/secondary_header.dart';
import 'package:eazytalk/widgets/video_call/call_history_item.dart';
import 'package:eazytalk/Screens/secondary_screens/video_call/video_call_screen.dart';
import 'package:eazytalk/l10n/app_localizations.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> with SingleTickerProviderStateMixin {
  final CallHistoryService _callHistoryService = CallHistoryService();
  final CallService _callService = CallService();
  
  // Duration cache to avoid recalculating
  final Map<String, String> _durationCache = {};
  
  // Tab controller
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Get call duration
  Future<String> _getCallDuration(CallModel call) async {
    // Check cache first
    if (_durationCache.containsKey(call.id)) {
      return _durationCache[call.id]!;
    }
    
    // Calculate duration
    final duration = await _callHistoryService.getCallDuration(call.id);
    
    // Format and cache
    final formatted = _callHistoryService.formatDuration(duration);
    _durationCache[call.id] = formatted;
    
    return formatted;
  }
  
  // Make a new call to a contact
  Future<void> _makeCall(CallModel previousCall) async {
    try {
      // Show loading indicator
      _showLoading();
      
      // Check if the call is for the current user (outgoing) or from someone else (incoming)
      final isOutgoing = previousCall.callerId == _callService.currentUserId;
      final receiverId = isOutgoing ? previousCall.receiverId : previousCall.callerId;
      final receiverName = isOutgoing ? previousCall.receiverName : previousCall.callerName;
      final receiverProfileImage = isOutgoing 
          ? previousCall.receiverProfileImageBase64
          : previousCall.callerProfileImageBase64;
      
      // Make a new call
      final call = await _callService.makeCall(
        receiverId: receiverId,
        receiverName: receiverName,
        receiverProfileImageBase64: receiverProfileImage,
        isVideoEnabled: previousCall.isVideoEnabled,
      );
      
      // Hide loading indicator
      Navigator.pop(context);
      
      if (call != null && mounted) {
        // Navigate to the video call screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              call: call,
              isIncoming: false,
            ),
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);
      
      _showError('Failed to start call: $e');
    }
  }
  
  // Delete a call record
  Future<void> _deleteCallRecord(String callId) async {
    final success = await _callHistoryService.deleteCallRecord(callId);
    
    if (!success) {
      _showError('Failed to delete call record');
    }
  }
  
  // Clear all call history
  Future<void> _clearAllHistory() async {
    final localizations = AppLocalizations.of(context);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('clear_all')),
        content: Text(localizations.translate('clear_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.translate('clear_all')),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Show loading indicator
    _showLoading();
    
    try {
      final success = await _callHistoryService.clearCallHistory();
      
      // Hide loading indicator
      Navigator.pop(context);
      
      if (!success) {
        _showError(localizations.translate('failed_load'));
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.pop(context);
      
      _showError('${localizations.translate('failed_load')}: $e');
    }
  }
  
  // Show loading dialog
  void _showLoading() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: 16.h),
            Text(
              localizations.translate('loading'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: AppColors.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            SecondaryHeader(
              title: localizations.translate('call_history'),
              onBackPressed: () => Navigator.pop(context),
              actionWidget: GestureDetector(
                  onTap: _clearAllHistory,
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.getTextPrimaryColor(context),
                    size: 24.sp,
                  ),
                ),
            ),
            
            // Tab bar
            Container(
              margin: EdgeInsets.only(top: 20.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: localizations.translate('all')),
                  Tab(text: localizations.translate('missed')),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All calls tab
                  _buildAllCallsTab(),
                  
                  // Missed calls tab
                  _buildMissedCallsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build all calls tab
  Widget _buildAllCallsTab() {
    final localizations = AppLocalizations.of(context);
    
    return StreamBuilder<List<CallModel>>(
      stream: _callHistoryService.getCallHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  localizations.translate('loading'),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: AppColors.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              localizations.translate('error_loading'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: Colors.red,
              ),
            ),
          );
        }
        
        final calls = snapshot.data ?? [];
        
        if (calls.isEmpty) {
          return _buildEmptyState(localizations.translate('no_call_history'));
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            final isCurrentUser = call.callerId == _callService.currentUserId;
            final callType = _callHistoryService.getCallType(call);
            
            return FutureBuilder<String>(
              future: _getCallDuration(call),
              builder: (context, durationSnapshot) {
                final duration = durationSnapshot.data ?? '';
                
                return CallHistoryItem(
                  call: call,
                  callType: callType,
                  duration: duration,
                  onTap: () => _makeCall(call),
                  onDelete: () => _deleteCallRecord(call.id),
                  isCurrentUser: isCurrentUser,
                );
              },
            );
          },
        );
      },
    );
  }
  
  // Build missed calls tab
  Widget _buildMissedCallsTab() {
    final localizations = AppLocalizations.of(context);
    
    return StreamBuilder<List<CallModel>>(
      stream: _callHistoryService.getMissedCalls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  localizations.translate('loading'),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: AppColors.getTextPrimaryColor(context),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              localizations.translate('error_loading'),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: Colors.red,
              ),
            ),
          );
        }
        
        final calls = snapshot.data ?? [];
        
        if (calls.isEmpty) {
          return _buildEmptyState(localizations.translate('no_missed_calls'));
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            
            return CallHistoryItem(
              call: call,
              callType: 'Missed',
              duration: '',
              onTap: () => _makeCall(call),
              onDelete: () => _deleteCallRecord(call.id),
              isCurrentUser: false,
            );
          },
        );
      },
    );
  }
  
  // Build empty state widget
  Widget _buildEmptyState(String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call_missed,
            size: 64.sp,
            color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18.sp,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}