import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class IssueProvider extends ChangeNotifier {
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Map<String, dynamic>> issues = [];
  String? errorMessage; // To store error messages

  Future<void> fetchIssues(String repoName, String state) async {
    log('Fetching issues for repo: $repoName===>State:$state');
    if (isLoading || !hasMore) return;

    isLoading = true;
    errorMessage = null; // Reset previous error
    notifyListeners();

    try {
      final dio = Dio();
      dio.options.headers["Authorization"] = ''; // Set your token here

      final response = await dio.get(
        'https://api.github.com/repos/$repoName/issues',
        queryParameters: {
          'state': state,
          'page': page,
          'per_page': 10,
        },
      );

      log('get data:${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) hasMore = false;

        issues.addAll(
            data.map((issue) => issue as Map<String, dynamic>).toList());
        page++;
        log('Issues fetched: $issues');
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
}
