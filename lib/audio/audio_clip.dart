part of simple_audio;

/** An [AudioClip] stores sound data. It can be played by an [AudioSource]
 * or played with [AudioMusic].
 */
class AudioClip {
  final AudioManager _manager;
  final String name;
  AudioBuffer _buffer;
  bool _hasError = false;
  String _errorString = '';
  bool _isReadyToPlay = false;

  AudioClip._internal(this._manager, this.name);

  void _empty() {
    _isReadyToPlay = false;
    _buffer = null;
  }

  /** Does this [AudioClip] have an error? */
  bool get hasError => _hasError;
  /** Human readable error */
  String get errorString => _errorString;

  void _clearError() {
    _hasError = false;
    _errorString = 'OK';
  }

  void _setError(String error) {
    _hasError = true;
    _errorString = error;
  }

  void _onDecode(AudioBuffer buffer) {
    if (buffer == null) {
      _empty();
      _setError('Error decoding buffer.');
      return;
    }
    _clearError();
    _buffer = buffer;
    _isReadyToPlay = true;
    print('ready');
  }

  void _onRequestSuccess(HttpRequest request) {
    var response = request.response;
    _manager._context.decodeAudioData(response,
                                      _onDecode,
                                      _onDecode);
  }

  void _onRequestError(HttpRequest request) {
    _empty();
    _setError('Error fetching data');
  }

  /** Fetch [url] and decode it into this [AudioClip] buffer. */
  void loadFrom(String url) {
    var request = new HttpRequest();
    request.responseType = 'arraybuffer';
    request.on.load.add((e) => _onRequestSuccess(request));
    request.on.error.add((e) => _onRequestError(request));
    request.on.abort.add((e) => _onRequestError(request));
    request.open('GET', url);
    request.send();
  }

  /** Make an empty buffer with [numberOfSampleFrames] in
   * each [numberOfChannels]. The buffer plays at a rate of [sampleRate].
   * The duration (in seconds) of the buffer is equal to:
   * numberOfSampleFrames / sampleRate
   */
  void makeBuffer(num numberOfSampleFrames, num numberOfChannels, num sampleRate) {
    _buffer = _manager._context.createBuffer(numberOfChannels,
                                             numberOfChannels,
                                             sampleRate);
  }

  /** Return the sample frames array for [channel] */
  Float32Array getSampleFramesForChannel(num channel) {
    if (_buffer == null) {
      return null;
    }
    return _buffer.getChannelData(channel);
  }

  /** Return the number of channels this buffer has */
  num get numberOfChannels {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.numberOfChannels;
  }

  /** Length of audio clip in seconds */
  num get length {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.duration;
  }

  /** Length of audio clip in samples */
  num get samples {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.length;
  }

  /** Samples per second */
  num get frequency {
    if (_buffer == null) {
      return 0;
    }
    return _buffer.sampleRate;
  }

  /** Is the audio clip ready to be played ? */
  bool get isReadyToPlay => _isReadyToPlay;
}
