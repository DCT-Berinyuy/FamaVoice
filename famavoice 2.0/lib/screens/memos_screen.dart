
import 'package:flutter/material.dart';
import 'package:famavoice/models/memo_model.dart';
import 'package:famavoice/services/memo_service.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class MemosScreen extends StatefulWidget {
  const MemosScreen({super.key});

  @override
  State<MemosScreen> createState() => _MemosScreenState();
}

class _MemosScreenState extends State<MemosScreen> {
  final MemoService _memoService = MemoService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Memo> _memos = [];
  bool _isRecording = false;
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final loadedMemos = await _memoService.loadMemos();
    setState(() {
      _memos = loadedMemos;
    });
  }

  Future<void> _startRecording() async {
    if (await _memoService.requestPermissions()) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _currentRecordingPath = '${directory.path}/memo_$timestamp.m4a';

        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            numChannels: 1,
            
          ),
          path: _currentRecordingPath!,
        );
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        debugPrint('Error starting recording: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final newMemo = Memo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'New Memo ${DateTime.now().toString().split('.')[0]}',
          filePath: path,
          createdAt: DateTime.now(),
        );
        await _memoService.saveMemo(newMemo);
        setState(() {
          _memos.add(newMemo);
          _isRecording = false;
          _currentRecordingPath = null;
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _playMemo(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
      _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing memo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/famavoice_logo.png',
              height: 30, // Adjust size as needed
            ),
            const SizedBox(width: 10),
            const Text('Voice Memos', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _memos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                                                Icon(Icons.mic_off, size: 80, color: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.6).round())),
                        const SizedBox(height: 20),
                        Text(
                          'No voice memos recorded yet.',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round())),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap the microphone button below to record your first memo.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _memos.length,
                    itemBuilder: (context, index) {
                      final memo = _memos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memo.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Recorded: ${memo.createdAt.toLocal().toString().split('.')[0]}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.primary),
                                    onPressed: () => _playMemo(memo.filePath),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                    onPressed: () async {
                                      await _memoService.deleteMemo(memo.id, memo.filePath);
                                      _loadMemos(); // Reload memos after deletion
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 80, // Make the button larger
              height: 80,
              child: FloatingActionButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                backgroundColor: _isRecording ? Colors.red : Theme.of(context).primaryColor,
                child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
