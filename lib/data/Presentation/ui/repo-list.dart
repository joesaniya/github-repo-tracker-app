import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:repo_tracker_app/data/Business%20Logic/search-provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Business Logic/issue-provider.dart';
import '../../Data Provider/Appcolor.dart';

class RepoList extends StatefulWidget {
  final String reponame;

  const RepoList({super.key, required this.reponame});

  @override
  State<RepoList> createState() => _RepoListState();
}

class _RepoListState extends State<RepoList> {
  String state = 'open';
  final ScrollController _scrollController = ScrollController();
  double? xAlign;
  Color? loginColor;
  Color? signInColor;
  /*@override
  void initState() {
    super.initState();
    xAlign = Appcolors.loginAlign;
    loginColor = Appcolors.selectedColor;
    signInColor = Appcolors.normalColor;

    _scrollController.addListener(() {
      final provider = Provider.of<IssueProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          provider.hasMore &&
          !provider.isLoading) {
        log('scroll repo:${widget.reponame}=>scroll state:$state');
        provider.fetchIssues(widget.reponame, state);
      }
    });
  }*/
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        final provider = Provider.of<IssueProvider>(context, listen: false);
        if (!provider.isLoading && provider.hasMore) {
          log('scroll repo:${widget.reponame}=>scroll state:$state');
          provider.fetchIssues(widget.reponame, state);
        }
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

                //sort
              ],
            ),
            body: provider.isLoading
                ? Center(child: SizedBox(child: CircularProgressIndicator()))
                : Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text('Sort:  '),
                                DropdownButton<String>(
                                  value: provider.sort,
                                  items: [
                                    DropdownMenuItem(
                                        value: 'created',
                                        child: Text('Created Date')),
                                    DropdownMenuItem(
                                        value: 'updated',
                                        child: Text('Updated Date')),
                                    DropdownMenuItem(
                                        value: 'comments',
                                        child: Text('Comments')),
                                  ],
                                  onChanged: (newSort) {
                                    if (newSort != null) {
                                      provider.setSort(newSort);
                                      provider.fetchIssues(
                                          widget.reponame, state);
                                    }
                                  },
                                ),
                              ],
                            ),

                            /*  DropdownButton<List<String>>(
                              hint: Text("Labels"),
                              items: [
                                DropdownMenuItem(
                                  value: ['bug'],
                                  child: Text('Bug'),
                                ),
                                DropdownMenuItem(
                                  value: ['enhancement'],
                                  child: Text('Enhancement'),
                                ),
                              ],
                              onChanged: (newLabels) {
                                if (newLabels != null) {
                                  provider.setLabels(newLabels);
                                  provider.fetchIssues(widget.reponame, state);
                                }
                              },
                            ),
                          */
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
                        child: provider.isLoading && provider.issues.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : provider.errorMessage != null
                                ? Center(
                                    child: Text(
                                      provider.errorMessage!,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: _scrollController,
                                    itemCount: provider.issues.length +
                                        (provider.hasMore ? 1 : 0),
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        height: 10,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      if (index == provider.issues.length) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }
                                      final issue = provider.issues[index];

                                      return GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse(issue[
                                              'html_url']); // Parse URL as a Uri object
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url,
                                                mode: LaunchMode
                                                    .externalApplication); // Ensure external app/browser is used
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

                                        /*  onTap: () async {
                                          final url = issue['html_url'];
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Could not launch $url')),
                                            );
                                            throw 'Could not launch $url';
                                          }
                                        },*/
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade100,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                issue['title'],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400),
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

  Widget buildTab(String label, String newState, IssueProvider provider) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (state != newState) {
            setState(() {
              state = newState;
            });
            provider.fetchIssues(widget.reponame, state);
          }
        },
        child: Container(
          width: Appcolors.width,
          height: Appcolors.height,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(xAlign!, 0),
                duration: Duration(milliseconds: 300),
                child: Container(
                  width: Appcolors.width * 0.5,
                  height: Appcolors.height,
                  decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50.0),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    xAlign = Appcolors.loginAlign;
                    loginColor = Appcolors.selectedColor;

                    signInColor = Appcolors.normalColor;
                  });
                },
                child: Align(
                  alignment: Alignment(-1, 0),
                  child: Container(
                    width: Appcolors.width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: loginColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    xAlign = Appcolors.signInAlign;
                    signInColor = Appcolors.selectedColor;

                    loginColor = Appcolors.normalColor;
                  });
                },
                child: Align(
                  alignment: Alignment(1, 0),
                  child: Container(
                    width: Appcolors.width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      'Signin',
                      style: TextStyle(
                        color: signInColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            });
            provider.fetchIssues(widget.reponame, state);
          }
        },
        child: Container(
          color: state == newState ? Colors.blue : Colors.grey,
          padding: EdgeInsets.all(8),
          child:
              Center(child: Text(label, style: TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
