import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cake_aide_basic/models/timer_recording.dart';
import 'package:cake_aide_basic/services/data_service.dart';
import 'package:cake_aide_basic/services/timer_background_service.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:cake_aide_basic/widgets/timer_icon.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with WidgetsBindingObserver {
  final DataService _dataService = DataService();
  Timer? _timer;
  Duration _currentDuration = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;
  String _currentActivity = '';
  DateTime? _startTime;
  final List<Duration> _pausedDurations = [];
  
  final TextEditingController _activityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _activityController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Reload timer state when app comes back to foreground
      _loadTimerState();
    }
  }

  // No-op background listener: we now rely on BackgroundFetch + polling via getCurrentDuration().

  Future<void> _loadTimerState() async {
    try {
      final isRunning = await TimerBackgroundService.isTimerRunning();
      final activity = await TimerBackgroundService.getCurrentActivity();
      final duration = await TimerBackgroundService.getCurrentDuration();
      
      if (mounted) {
        setState(() {
          _isRunning = isRunning;
          _currentActivity = activity ?? '';
          _currentDuration = duration ?? Duration.zero;
          _isPaused = !isRunning && duration != null && duration.inSeconds > 0;
        });
        
        _activityController.text = activity ?? '';
        
        // Start UI timer if background timer is running
        if (isRunning) {
          _startUITimer();
        }
      }
    } catch (e) {
      debugPrint('Timer state load error: $e');
      // Fallback to default state
      if (mounted) {
        setState(() {
          _isRunning = false;
          _isPaused = false;
          _currentActivity = '';
          _currentDuration = Duration.zero;
        });
      }
    }
  }

  void _startTimer() async {
    if (_currentActivity.trim().isEmpty) {
      _showActivityDialog();
      return;
    }

    try {
      // Start background service
      await TimerBackgroundService.startTimer(_currentActivity);
      
      setState(() {
        _isRunning = true;
        _isPaused = false;
        _startTime ??= DateTime.now();
      });

      _startUITimer();
    } catch (e) {
      debugPrint('Timer start error: $e');
      // Fallback to UI-only timer for web preview
      setState(() {
        _isRunning = true;
        _isPaused = false;
        _startTime ??= DateTime.now();
        _currentDuration = Duration.zero;
      });
      _startUITimer();
    }
  }

  void _startUITimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final duration = await TimerBackgroundService.getCurrentDuration();
        if (mounted && duration != null) {
          setState(() {
            _currentDuration = duration;
          });
        }
      } catch (e) {
        // Fallback: increment duration manually if background service fails
        if (mounted && _isRunning && _startTime != null) {
          final elapsed = DateTime.now().difference(_startTime!);
          setState(() {
            _currentDuration = elapsed;
          });
        }
      }
    });
  }

  void _pauseTimer() async {
    _timer?.cancel();
    
    try {
      await TimerBackgroundService.pauseTimer();
    } catch (e) {
      debugPrint('Timer pause error: $e');
      // Store pause state for fallback
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        _pausedDurations.add(elapsed);
      }
    }
    
    setState(() {
      _isRunning = false;
      _isPaused = true;
    });
  }

  void _resumeTimer() async {
    try {
      await TimerBackgroundService.resumeTimer();
    } catch (e) {
      debugPrint('Timer resume error: $e');
      // Fallback: reset start time for UI timer
      _startTime = DateTime.now();
    }
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    
    _startUITimer();
  }

  void _stopTimer() async {
    _timer?.cancel();
    
    try {
      await TimerBackgroundService.stopTimer();
    } catch (e) {
      debugPrint('Timer stop error: $e');
      // Continue with stop process even if background service fails
    }
    
    if (_currentDuration.inSeconds > 0) {
      _showSaveDialog();
    } else {
      _resetTimer();
    }
  }

  void _resetTimer() async {
    _timer?.cancel();
    
    try {
      await TimerBackgroundService.stopTimer();
    } catch (e) {
      debugPrint('Timer reset error: $e');
      // Continue with reset even if background service fails
    }
    
    setState(() {
      _currentDuration = Duration.zero;
      _isRunning = false;
      _isPaused = false;
      _currentActivity = '';
      _startTime = null;
      _pausedDurations.clear();
    });
    _activityController.clear();
  }

  void _showActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('What are you working on?'),
        content: TextField(
          controller: _activityController,
          decoration: const InputDecoration(
            hintText: 'e.g., Baking chocolate cake',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentActivity = _activityController.text.trim();
              });
              Navigator.of(context).pop();
              if (_currentActivity.isNotEmpty) {
                _startTimer();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Save Recording?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity: $_currentActivity'),
            Text('Duration: ${_formatDuration(_currentDuration)}'),
            const SizedBox(height: 8),
            const Text('Would you like to save this time recording?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveRecording();
              Navigator.of(context).pop();
              _resetTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveRecording() {
    if (_startTime != null && _currentDuration.inSeconds > 0) {
      final recording = TimerRecording(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        activity: _currentActivity,
        startTime: _startTime!,
        endTime: _startTime!.add(_currentDuration),
        duration: _currentDuration,
        pausedDurations: List.from(_pausedDurations),
        createdAt: DateTime.now(),
      );
      
      _dataService.addTimerRecording(recording);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time recording saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Work Timer'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: GradientDecorations.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          if (_currentDuration.inSeconds > 0)
            IconButton(
              onPressed: _resetTimer,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Timer',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Current Activity Card
            if (_currentActivity.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Currently Working On',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentActivity,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 40),

            // Timer Display
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isRunning 
                    ? GradientDecorations.primaryGradient
                    : LinearGradient(
                        colors: [
                          Colors.grey[300]!,
                          Colors.grey[400]!,
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _formatDuration(_currentDuration),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Pause Button
                _buildControlButton(
                  onPressed: _isRunning ? _pauseTimer : (_isPaused ? _resumeTimer : _startTimer),
                  icon: _isRunning 
                      ? Icons.pause 
                      : (_isPaused ? Icons.play_arrow : Icons.play_arrow),
                  label: _isRunning 
                      ? 'Pause' 
                      : (_isPaused ? 'Resume' : 'Start'),
                  color: _isRunning ? Colors.orange : Colors.green,
                ),

                // Stop Button
                _buildControlButton(
                  onPressed: (_isRunning || _isPaused) ? _stopTimer : null,
                  icon: Icons.stop,
                  label: 'Stop',
                  color: Colors.red,
                ),
              ],
            ),

            const Spacer(),

            // Recent Recordings
            if (_dataService.timerRecordings.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Recordings',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to full recordings list
                            _showAllRecordings();
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      _dataService.timerRecordings.take(3).length,
                      (index) {
                        final recording = _dataService.timerRecordings[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.pink,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  recording.activity,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                _formatDuration(recording.duration),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onPressed != null ? color : Colors.grey[300],
            boxShadow: onPressed != null ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(40),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: onPressed != null ? color : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showAllRecordings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Time Recordings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _dataService.timerRecordings.length,
                itemBuilder: (context, index) {
                  final recording = _dataService.timerRecordings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.pink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: TimerIcon(size: 20, fallbackColor: Colors.pink),
                        ),
                      ),
                      title: Text(
                        recording.activity,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Started: ${recording.startTime.hour}:${recording.startTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDuration(recording.duration),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                          Text(
                            '${recording.createdAt.day}/${recording.createdAt.month}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}