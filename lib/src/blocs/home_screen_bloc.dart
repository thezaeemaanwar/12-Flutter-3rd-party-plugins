import 'dart:async';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:third_app_plugins/src/blocs/bloc_base.dart';
import 'package:third_app_plugins/src/repositories/repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:third_app_plugins/src/models/photos.dart';
import 'package:third_app_plugins/src/models/state.dart';

class HomeScreenBloc extends BlocBase {
  static Repository _repository = Repository();
  PublishSubject<String> _query;

  init() {
    _query = PublishSubject<String>();
  }

  Stream<Photos> get photosList => _query.stream
      .debounceTime(Duration(milliseconds: 300))
      .where((String value) => value.isNotEmpty)
      .distinct()
      .transform(streamTransformer);

  final streamTransformer = StreamTransformer<String, Photos>.fromHandlers(
      handleData: (query, sink) async {
    State state = await _repository.imageData(query);
    if (state is SuccessState) {
      sink.add(state.value);
    } else {
      sink.addError((state as ErrorState).msg);
    }
  });

  Function(String) get changeQuery => _query.sink.add;

  @override
  void dispose() {
    _query.close();
  }

  String getDescription(Result result) {
    return (result.description == null || result.description.isEmpty)
        ? result.altDescription
        : result.description;
  }

  void shareImage(String url) {
    _repository.getImageToShare(url).then((Uint8List value) async {
      await Share.file("Share via:", "image.png", value, "image/png");
    });
  }
}

final bloc = HomeScreenBloc();
