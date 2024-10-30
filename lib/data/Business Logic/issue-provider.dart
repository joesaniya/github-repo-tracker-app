import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class IssueProvider extends ChangeNotifier {
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Map<String, dynamic>> issues = [];
  String? errorMessage;

  String sort = 'created';
  List<String> labels = [];

  Future<void> fetchIssues(String repoName, String state) async {
    log('Fetching issues for repo: $repoName ===> State: $state');

    if (isLoading || !hasMore) return;

    if (issues.isEmpty || page == 1) {
      hasMore = true;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final dio = Dio();
      final String token =
          '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'; // Use your GitHub token
      dio.options.headers['Authorization'] = 'token $token';

      // Check rate limits
      final rateLimitResponse = await dio.get(
        'https://api.github.com/rate_limit',
        options: Options(
          headers: {
            'Authorization': 'token $token',
          },
        ),
      );

      if (rateLimitResponse.statusCode == 200) {
        final rateLimitData = rateLimitResponse.data;
        final remainingRequests = rateLimitData['rate']['remaining'];
        final resetTime = rateLimitData['rate']['reset'];

        log('Remaining requests: $remainingRequests');
        if (remainingRequests == 0) {
          final resetDateTime =
              DateTime.fromMillisecondsSinceEpoch(resetTime * 1000);
          errorMessage =
              'Rate limit exceeded. Try again at ${resetDateTime.toLocal()}';
          hasMore =
              false; // No more requests can be made until rate limit resets
          notifyListeners(); // Notify listeners for UI update
          return; // Exit the method if rate limit is exceeded
        }
      } else {
        errorMessage =
            'Failed to fetch rate limits: ${rateLimitResponse.statusCode}';
        notifyListeners();
        return;
      }

      // Fetch issues
      final response = await dio.get(
        'https://api.github.com/repos/$repoName/issues',
        queryParameters: {
          'state': state,
          'page': page,
          'per_page': 10,
          'sort': sort,
          'labels': labels.join(','),
        },
      );

      log('Fetched data from: ${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          hasMore = false;
        } else {
          issues.addAll(
            data.map((issue) => issue as Map<String, dynamic>).toList(),
          );
          page++;
          log('Issues fetched: $issues');
        }
      } else {
        hasMore = false;
        errorMessage = 'Failed to fetch issues: ${response.statusCode}';
      }
    } catch (e) {
      log('Failed to fetch issues: $e');
      errorMessage = 'Error fetching issues. Please try again later.';
      hasMore = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchIssues1(String repoName, String state) async {
    log('Fetching issues for repo: $repoName ===> State: $state');

    // Prevent multiple simultaneous fetches
    if (isLoading || !hasMore) return;

    // Reset state if there are issues already loaded
    if (issues.isEmpty || page == 1) {
      hasMore = true; // Reset hasMore for new state
    }

    isLoading = true;
    errorMessage = null; // Reset previous error
    notifyListeners();

    try {
      final dio = Dio();

      final response = await dio.get(
        'https://api.github.com/repos/$repoName/issues',
        queryParameters: {
          'state': state,
          'page': page,
          'per_page': 10,
          'sort': sort,
          'labels': labels.join(','),
        },
      );

      log('Fetched data from: ${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          hasMore = false; // No more issues to load
        } else {
          issues.addAll(
            data.map((issue) => issue as Map<String, dynamic>).toList(),
          );
          page++;
          log('Issues fetched: $issues');
        }
      } else {
        hasMore = false;
        errorMessage = 'Failed to fetch issues: ${response.statusCode}';
      }
    } catch (e) {
      log('Failed to fetch issues: $e');
      errorMessage = 'Error fetching issues. Please try again later.';
      hasMore = false;
    } finally {
      isLoading = false;
      notifyListeners(); // Always notify at the end to update UI
    }
  }

  void setSort(String newSort) {
    sort = newSort;
    notifyListeners();
  }

  void setLabels(List<String> newLabels) {
    labels = newLabels;
    notifyListeners();
  }
}
