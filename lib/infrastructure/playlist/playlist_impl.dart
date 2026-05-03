import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fluxtube/core/api_client.dart';
import 'package:fluxtube/domain/core/api_end_points.dart';
import 'package:fluxtube/domain/core/failure/main_failure.dart';
import 'package:fluxtube/domain/playlist/models/invidious/invidious_playlist_resp.dart';
import 'package:fluxtube/domain/playlist/models/piped/playlist_resp.dart';
import 'package:fluxtube/domain/playlist/playlist_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: PlaylistService)
class PlaylistImpl implements PlaylistService {
  @override
  Future<Either<MainFailure, PlaylistResp>> getPlaylistData({
    required String playlistId,
  }) async {
    try {
      log('${ApiEndPoints.playlist}$playlistId');
      final Response response =
          await ApiClient.dio.get('${ApiEndPoints.playlist}$playlistId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(PlaylistResp.fromJson(response.data));
      } else {
        log('Err on getPlaylistData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getPlaylistData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, PlaylistResp>> getMorePlaylistVideos({
    required String playlistId,
    required String nextPage,
  }) async {
    try {
      final url =
          '${ApiEndPoints.morePlaylistVideos}$playlistId?nextpage=${Uri.encodeComponent(nextPage)}';
      log(url);
      final Response response = await ApiClient.dio.get(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(PlaylistResp.fromJson(response.data));
      } else {
        log('Err on getMorePlaylistVideos: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getMorePlaylistVideos: $e');
      return const Left(MainFailure.clientFailure());
    }
  }

  @override
  Future<Either<MainFailure, InvidiousPlaylistResp>> getInvidiousPlaylistData({
    required String playlistId,
  }) async {
    try {
      log('${InvidiousApiEndpoints.playlist}$playlistId');
      final Response response = await ApiClient.dio
          .get('${InvidiousApiEndpoints.playlist}$playlistId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(InvidiousPlaylistResp.fromJson(response.data));
      } else {
        log('Err on getInvidiousPlaylistData: ${response.statusCode}');
        return const Left(MainFailure.serverFailure());
      }
    } catch (e) {
      log('Err on getInvidiousPlaylistData: $e');
      return const Left(MainFailure.clientFailure());
    }
  }
}
