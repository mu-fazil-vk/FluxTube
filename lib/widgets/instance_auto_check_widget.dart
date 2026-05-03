import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluxtube/application/application.dart';
import 'package:fluxtube/core/colors.dart';
import 'package:fluxtube/core/constants.dart';
import 'package:fluxtube/core/enums.dart';
import 'package:fluxtube/domain/settings/models/instance.dart';
import 'package:lottie/lottie.dart';

class InstanceAutoCheckWidget extends StatefulWidget {
  const InstanceAutoCheckWidget({
    super.key,
    required this.videoId,
    required this.onRetry,
    this.lottie = 'assets/cat-404.zip',
    this.errorMessage,
  });

  final String videoId;
  final VoidCallback onRetry;
  final String lottie;
  final String? errorMessage;

  @override
  State<InstanceAutoCheckWidget> createState() => _InstanceAutoCheckWidgetState();
}

class _InstanceAutoCheckWidgetState extends State<InstanceAutoCheckWidget> {
  bool _isChecking = false;
  String _statusMessage = '';
  String? _currentCheckingInstance;
  int _checkedCount = 0;
  int _totalInstances = 0;
  Instance? _workingInstance;
  bool _checkComplete = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final ytService = settingsState.ytService;
        final instances = ytService == YouTubeServices.piped.name
            ? settingsState.pipedInstances
            : settingsState.invidiousInstances;

        final screenHeight = MediaQuery.of(context).size.height;

        return SizedBox(
          height: screenHeight - 150, // Account for app bar and safe area
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: LottieBuilder.asset(
                  widget.lottie,
                  width: 180,
                  height: 180,
                ),
              ),
            kHeightBox10,
            Text(
              _getErrorTitle(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            kHeightBox5,
            Text(
              _getErrorSubtitle(),
              style: TextStyle(
                color: kGreyColor,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            kHeightBox20,
            // Retry button
            TextButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            kHeightBox10,
            const Divider(indent: 40, endIndent: 40),
            kHeightBox10,
            // Auto-check section
            if (_isChecking) ...[
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(kRedColor),
                          ),
                        ),
                        kWidthBox10,
                        Flexible(
                          child: Text(
                            'Checking instances ($_checkedCount/$_totalInstances)',
                            style: TextStyle(
                              color: isDarkMode ? kWhiteColor : kBlackColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    kHeightBox10,
                    if (_currentCheckingInstance != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? kWhiteColor.withValues(alpha: 0.05)
                              : kGreyOpacityColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.dns_outlined,
                              size: 16,
                              color: kGreyColor,
                            ),
                            kWidthBox10,
                            Expanded(
                              child: Text(
                                _currentCheckingInstance!,
                                style: TextStyle(
                                  color: kGreyColor,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    kHeightBox10,
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    kHeightBox10,
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isChecking = false;
                          _statusMessage = 'Cancelled';
                        });
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: kGreyColor),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_checkComplete && _workingInstance != null) ...[
              // Found working instance
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        kWidthBox10,
                        const Text(
                          'Found working instance!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    kHeightBox10,
                    Text(
                      _workingInstance!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    kHeightBox5,
                    Text(
                      _workingInstance!.api,
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                    ),
                    kHeightBox15,
                    ElevatedButton.icon(
                      onPressed: () => _switchAndRetry(_workingInstance!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: kWhiteColor,
                      ),
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Switch & Retry'),
                    ),
                  ],
                ),
              ),
            ] else if (_checkComplete && _workingInstance == null) ...[
              // No working instance found
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        kWidthBox10,
                        const Text(
                          'No working instance found',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    kHeightBox10,
                    Text(
                      'All available instances failed to load this video. Try again later or switch to a different YouTube service.',
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Initial state - show auto-check button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Auto-find a working instance?',
                      style: TextStyle(
                        color: isDarkMode ? kWhiteColor : kBlackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    kHeightBox5,
                    Text(
                      'We\'ll test ${instances.length} available instances to find one that works',
                      style: TextStyle(
                        color: kGreyColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    kHeightBox15,
                    ElevatedButton.icon(
                      onPressed: instances.isEmpty
                          ? null
                          : () => _startInstanceCheck(instances, ytService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRedColor,
                        foregroundColor: kWhiteColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.search, size: 18),
                      label: const Text('Find Working Instance'),
                    ),
                  ],
                ),
              ),
            ],
            ],
          ),
        );
      },
    );
  }

  String _getErrorTitle() {
    final msg = widget.errorMessage?.toLowerCase() ?? '';
    if (msg.contains('paid') || msg.contains('purchase')) {
      return 'Paid Video';
    } else if (msg.contains('member') || msg.contains('membership')) {
      return 'Members Only';
    } else if (msg.contains('age') || msg.contains('sign in')) {
      return 'Age Restricted';
    } else if (msg.contains('private')) {
      return 'Private Video';
    } else if (msg.contains('unavailable') || msg.contains('not available')) {
      return 'Video Unavailable';
    } else if (msg.contains('live') || msg.contains('premiere')) {
      return 'Not Yet Available';
    }
    return 'Video Unavailable';
  }

  String _getErrorSubtitle() {
    final msg = widget.errorMessage?.toLowerCase() ?? '';
    if (msg.contains('paid') || msg.contains('purchase')) {
      return 'This video requires purchase to watch';
    } else if (msg.contains('member') || msg.contains('membership')) {
      return 'This video is only available for channel members';
    } else if (msg.contains('age') || msg.contains('sign in')) {
      return 'This video is age-restricted and cannot be played';
    } else if (msg.contains('private')) {
      return 'This video is private';
    } else if (msg.contains('live') || msg.contains('premiere')) {
      return 'This video has not started yet';
    }
    return 'The current instance may be experiencing issues';
  }

  Future<void> _startInstanceCheck(List<Instance> instances, String ytService) async {
    setState(() {
      _isChecking = true;
      _checkedCount = 0;
      _totalInstances = instances.length;
      _statusMessage = 'Starting...';
      _workingInstance = null;
      _checkComplete = false;
    });

    for (int i = 0; i < instances.length; i++) {
      if (!_isChecking) break; // Cancelled

      final instance = instances[i];
      setState(() {
        _currentCheckingInstance = instance.name;
        _checkedCount = i + 1;
        _statusMessage = 'Testing ${instance.name}...';
      });

      try {
        String testUrl;
        if (ytService == YouTubeServices.piped.name) {
          testUrl = '${instance.api}streams/${widget.videoId}';
        } else {
          // Invidious
          testUrl = '${instance.api}/api/v1/videos/${widget.videoId}';
        }

        log('Testing instance: ${instance.name} - $testUrl');

        final response = await ApiClient.dio.get(
          testUrl,
          options: Options(
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Found a working instance!
          log('Found working instance: ${instance.name}');
          setState(() {
            _workingInstance = instance;
            _isChecking = false;
            _checkComplete = true;
            _statusMessage = 'Found working instance!';
          });
          return;
        } else {
          log('Instance ${instance.name} failed with status: ${response.statusCode}');
        }
      } catch (e) {
        log('Instance ${instance.name} error: $e');
      }

      // Small delay between checks
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (_isChecking) {
      // Finished checking all instances
      setState(() {
        _isChecking = false;
        _checkComplete = true;
        _statusMessage = 'Check complete';
      });
    }
  }

  void _switchAndRetry(Instance instance) {
    // Switch to the working instance
    BlocProvider.of<SettingsBloc>(context).add(
      SettingsEvent.setInstance(instanceApi: instance.api),
    );

    // Small delay to let the instance change propagate
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onRetry();
    });
  }
}
