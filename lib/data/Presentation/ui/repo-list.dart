import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Business Logic/issue-provider.dart';

class RepoList extends StatefulWidget {
  final String reponame;

  const RepoList({super.key, required this.reponame});

  @override
  State<RepoList> createState() => _RepoListState();
}

class _RepoListState extends State<RepoList> {
  String state = 'open';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final provider = Provider.of<IssueProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          provider.hasMore &&
          !provider.isLoading) {
        log('Fetching more issues for repo: ${widget.reponame} in state: $state');
        provider.fetchIssues(widget.reponame, state);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('Repo: ${widget.reponame}');
    return ChangeNotifierProvider(
      create: (_) => IssueProvider()..fetchIssues(widget.reponame, state),
      child: Consumer<IssueProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Repo Issues'),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    provider.fetchIssues(widget.reponame, state);
                  },
                ),
              ],
            ),
            body: provider.isLoading && provider.issues.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            _buildTab('Open', 'open', provider),
                            _buildTab('Closed', 'closed', provider),
                          ],
                        ),
                      ),
                      Expanded(
                        child: provider.errorMessage != null
                            ? Center(
                                child: Text(
                                  provider.errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              )
                            : ListView.separated(
                                controller: _scrollController,
                                itemCount: provider.issues.length +
                                    (provider.hasMore
                                        ? 1
                                        : 0), // Add loading indicator if more issues to load
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 10);
                                },
                                itemBuilder: (context, index) {
                                  if (index == provider.issues.length) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final issue = provider.issues[index];

                                  return GestureDetector(
                                    onTap: () async {
                                      final url = Uri.parse(issue['html_url']);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Could not launch $url')),
                                        );
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade100,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            issue['title'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          Text(
                                              'Issue #${issue['number']} by ${issue['user']['login']} created at ${issue['created_at']}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, String newState, IssueProvider provider) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (state != newState) {
            setState(() {
              state = newState;
              provider.issues
                  .clear(); // Clear existing issues when switching states
              provider.page = 1; // Reset page to 1
              provider.hasMore = true; // Reset hasMore
            });
            provider.fetchIssues(widget.reponame, state);
          }
        },
        child: Container(
          height: 50,
          color: state == newState ? Colors.teal.shade500 : Colors.grey,
          padding: EdgeInsets.all(8),
          child:
              Center(child: Text(label, style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
