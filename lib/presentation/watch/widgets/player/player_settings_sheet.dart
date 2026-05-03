import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluxtube/domain/watch/models/newpipe/newpipe_subtitle.dart';
import 'package:fluxtube/domain/watch/playback/models/stream_quality_info.dart';
import 'package:fluxtube/domain/watch/playback/newpipe_stream_helper.dart';

/// Settings page enum - exported for direct navigation
enum SettingsPage {
  main,
  speed,
  quality,
  captions,
  audioTrack,
  resize,
}

/// YouTube-like player settings bottom sheet
class PlayerSettingsSheet extends StatefulWidget {
  const PlayerSettingsSheet({
    super.key,
    required this.currentSpeed,
    required this.speeds,
    required this.onSpeedChanged,
    required this.currentQuality,
    required this.qualities,
    required this.onQualityChanged,
    required this.subtitles,
    required this.currentSubtitle,
    required this.onSubtitleChanged,
    required this.isLive,
    this.initialPage = SettingsPage.main,
    this.audioTracks,
    this.currentAudioTrackId,
    this.onAudioTrackChanged,
    this.currentFitMode,
    this.onFitModeChanged,
  });

  final double currentSpeed;
  final List<double> speeds;
  final Function(double) onSpeedChanged;
  final String? currentQuality;
  final List<StreamQualityInfo>? qualities;
  final Function(String) onQualityChanged;
  final List<NewPipeSubtitle> subtitles;
  final String? currentSubtitle;
  final Function(String?) onSubtitleChanged;
  final bool isLive;
  final SettingsPage initialPage;
  final List<AudioTrackInfo>? audioTracks;
  final String? currentAudioTrackId;
  final Function(String)? onAudioTrackChanged;
  final String? currentFitMode;
  final Function(String)? onFitModeChanged;

  @override
  State<PlayerSettingsSheet> createState() => _PlayerSettingsSheetState();
}

class _PlayerSettingsSheetState extends State<PlayerSettingsSheet> {
  late SettingsPage _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _buildCurrentPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case SettingsPage.main:
        return _buildMainPage();
      case SettingsPage.speed:
        return _buildSpeedPage();
      case SettingsPage.quality:
        return _buildQualityPage();
      case SettingsPage.captions:
        return _buildCaptionsPage();
      case SettingsPage.audioTrack:
        return _buildAudioTrackPage();
      case SettingsPage.resize:
        return _buildResizePage();
    }
  }

  Widget _buildMainPage() {
    return Column(
      key: const ValueKey('main'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHandle(),
        const SizedBox(height: 8),

        // Speed option (only for non-live)
        if (!widget.isLive)
          _buildSettingsTile(
            icon: CupertinoIcons.speedometer,
            title: 'Playback speed',
            value: widget.currentSpeed == 1.0
                ? 'Normal'
                : '${widget.currentSpeed}x',
            onTap: () => setState(() => _currentPage = SettingsPage.speed),
          ),

        // Quality option
        if (widget.qualities != null && widget.qualities!.isNotEmpty)
          _buildSettingsTile(
            icon: CupertinoIcons.gear_alt,
            title: 'Quality',
            value: widget.currentQuality ?? 'Auto',
            onTap: () => setState(() => _currentPage = SettingsPage.quality),
          ),

        // Captions option
        if (widget.subtitles.isNotEmpty)
          _buildSettingsTile(
            icon: CupertinoIcons.captions_bubble,
            title: 'Captions',
            value: widget.currentSubtitle ?? 'Off',
            onTap: () => setState(() => _currentPage = SettingsPage.captions),
          ),

        // Audio track option (only show if multiple tracks available)
        if (widget.audioTracks != null && widget.audioTracks!.length > 1)
          _buildSettingsTile(
            icon: CupertinoIcons.music_note,
            title: 'Audio track',
            value: _getCurrentAudioTrackLabel(),
            onTap: () => setState(() => _currentPage = SettingsPage.audioTrack),
          ),

        if (widget.onFitModeChanged != null)
          _buildSettingsTile(
            icon: CupertinoIcons.arrow_up_left_arrow_down_right,
            title: 'Resize',
            value: _fitModeLabel(widget.currentFitMode ?? 'contain'),
            onTap: () => setState(() => _currentPage = SettingsPage.resize),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  String _getCurrentAudioTrackLabel() {
    if (widget.audioTracks == null || widget.audioTracks!.isEmpty) {
      return 'Default';
    }
    final currentTrack = widget.audioTracks!.firstWhere(
      (t) => t.trackId == widget.currentAudioTrackId,
      orElse: () => widget.audioTracks!.first,
    );
    return currentTrack.displayName;
  }

  Widget _buildSpeedPage() {
    return Column(
      key: const ValueKey('speed'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader('Playback speed'),
        const Divider(color: Colors.white12, height: 1),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.speeds.length,
          itemBuilder: (context, index) {
            final speed = widget.speeds[index];
            final isSelected = speed == widget.currentSpeed;
            final label = speed == 1.0 ? 'Normal' : '${speed}x';

            return _buildOptionTile(
              title: label,
              isSelected: isSelected,
              onTap: () {
                widget.onSpeedChanged(speed);
                Navigator.pop(context);
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQualityPage() {
    return Column(
      key: const ValueKey('quality'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader('Quality',
            showBackButton: widget.initialPage == SettingsPage.main),
        const Divider(color: Colors.white12, height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.qualities!.length,
            itemBuilder: (context, index) {
              final quality = widget.qualities![index];
              final isSelected = quality.label == widget.currentQuality;

              return _buildOptionTile(
                title: quality.displayLabel,
                subtitle: _getQualitySubtitle(quality),
                isSelected: isSelected,
                onTap: () {
                  widget.onQualityChanged(quality.label);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCaptionsPage() {
    return Column(
      key: const ValueKey('captions'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader('Captions',
            showBackButton: widget.initialPage == SettingsPage.main),
        const Divider(color: Colors.white12, height: 1),

        // Off option
        _buildOptionTile(
          title: 'Off',
          isSelected: widget.currentSubtitle == null,
          onTap: () {
            widget.onSubtitleChanged(null);
            Navigator.pop(context);
          },
        ),

        // Subtitle options
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.subtitles.length,
            itemBuilder: (context, index) {
              final subtitle = widget.subtitles[index];
              final isSelected =
                  subtitle.languageCode == widget.currentSubtitle;
              final label = _getSubtitleLabel(subtitle);

              return _buildOptionTile(
                title: label,
                subtitle:
                    subtitle.autoGenerated == true ? 'Auto-generated' : null,
                isSelected: isSelected,
                onTap: () {
                  widget.onSubtitleChanged(subtitle.languageCode);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAudioTrackPage() {
    return Column(
      key: const ValueKey('audioTrack'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader('Audio track',
            showBackButton: widget.initialPage == SettingsPage.main),
        const Divider(color: Colors.white12, height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.audioTracks!.length,
            itemBuilder: (context, index) {
              final track = widget.audioTracks![index];
              final isSelected = track.trackId == widget.currentAudioTrackId;

              return _buildOptionTile(
                title: track.displayName,
                subtitle: _getAudioTrackSubtitle(track),
                isSelected: isSelected,
                onTap: () {
                  widget.onAudioTrackChanged?.call(track.trackId);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildResizePage() {
    const modes = ['contain', 'cover', 'fill'];
    return Column(
      key: const ValueKey('resize'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader('Resize',
            showBackButton: widget.initialPage == SettingsPage.main),
        const Divider(color: Colors.white12, height: 1),
        ...modes.map((mode) {
          return _buildOptionTile(
            title: _fitModeLabel(mode),
            subtitle: switch (mode) {
              'cover' => 'Zoom to fill',
              'fill' => 'Stretch to fill',
              _ => 'Fit entire video',
            },
            isSelected: (widget.currentFitMode ?? 'contain') == mode,
            onTap: () {
              widget.onFitModeChanged?.call(mode);
              Navigator.pop(context);
            },
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  String _fitModeLabel(String mode) {
    return switch (mode) {
      'cover' => 'Zoom',
      'fill' => 'Fill',
      _ => 'Fit',
    };
  }

  String? _getAudioTrackSubtitle(AudioTrackInfo track) {
    if (track.isOriginal) {
      return 'Original';
    }
    return null;
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, {bool showBackButton = true}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () => setState(() => _currentPage = SettingsPage.main),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.chevron_left,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  CupertinoIcons.xmark,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: width),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: width * 0.34),
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: width),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      child: isSelected
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getQualitySubtitle(StreamQualityInfo quality) {
    final parts = <String>[];
    if (quality.fps != null && quality.fps! > 30) {
      parts.add('${quality.fps}fps');
    }
    if (quality.format != null) {
      parts.add(quality.format!.toUpperCase());
    }
    if (quality.requiresMerging) {
      parts.add('HD');
    }
    return parts.join(' • ');
  }

  String _getSubtitleLabel(NewPipeSubtitle subtitle) {
    final code = subtitle.languageCode ?? 'Unknown';
    // Map common language codes to names
    final languageMap = {
      'en': 'English',
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'zh-CN': 'Chinese (Simplified)',
      'zh-TW': 'Chinese (Traditional)',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'id': 'Indonesian',
      'tr': 'Turkish',
      'vi': 'Vietnamese',
      'th': 'Thai',
      'nl': 'Dutch',
      'pl': 'Polish',
      'sv': 'Swedish',
      'no': 'Norwegian',
      'da': 'Danish',
      'fi': 'Finnish',
    };
    return languageMap[code] ?? code;
  }
}
