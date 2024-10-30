import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class IssueProvider extends ChangeNotifier {
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Map<String, dynamic>> issues = [];
  String? errorMessage;


  String sort = 'created'; 
  List<String> labels = []; 

  Future<void> fetchIssues(String repoName, String state) async {
    if (isLoading || !hasMore) return;

    if (issues.isNotEmpty) {
      issues.clear();
      page = 1;
      hasMore = true;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.github.com/repos/$repoName/issues',
        queryParameters: {
          'state': state,
          'page': page,
          'per_page': 10,
          'sort': sort, // Add sorting by 'created', 'updated', or 'comments'
          'labels': labels.join(','), // Comma-separated labels
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          hasMore = false;
        } else {
          issues.addAll(
              data.map((issue) => issue as Map<String, dynamic>).toList());
          page++;
        }
      } else {
        hasMore = false;
        errorMessage = 'Failed to fetch issues: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error fetching issues. Please try again later.';
      hasMore = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Methods to set sorting and filtering options
  void setSort(String newSort) {
    sort = newSort;
    notifyListeners();
  }

  void setLabels(List<String> newLabels) {
    labels = newLabels;
    notifyListeners();
  }
}

class IssueProviderr extends ChangeNotifier {
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Map<String, dynamic>> issues = [];
  String? errorMessage; // To store error messages

  Future<void> fetchIssues(String repoName, String state) async {
    log('Fetching issues for repo: $repoName ===> State: $state');

    if (isLoading || !hasMore) return;

    if (issues.isNotEmpty) {
      issues.clear();
      page = 1;
      hasMore = true;
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
        },
      );

      log('Fetched data from: ${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          hasMore = false;
        } else {
          issues.addAll(
              data.map((issue) => issue as Map<String, dynamic>).toList());
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

  Future<void> fetchIssuess(String repoName, String state) async {
    log('Fetching issues for repo: $repoName ===> State: $state');

    // Check if already loading or if there's no more data to fetch
    if (isLoading || !hasMore) return;

    // Reset issues and page when changing state
    if (issues.isNotEmpty) {
      issues.clear();
      page = 1;
      hasMore = true; // Reset hasMore for new state
    }

    isLoading = true;
    errorMessage = null; // Reset previous error
    notifyListeners();

    try {
      final dio = Dio();
      dio.options.headers["Authorization"] =
          ''; // Set your token here if required

      final response = await dio.get(
        'https://api.github.com/repos/$repoName/issues',
        queryParameters: {
          'state': state,
          'page': page,
          'per_page': 10,
        },
      );

      log('Fetched data from: ${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          hasMore = false;
        } else {
          issues.addAll(
              data.map((issue) => issue as Map<String, dynamic>).toList());
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
}
