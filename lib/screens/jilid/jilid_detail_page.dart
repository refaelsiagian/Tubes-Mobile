import 'package:flutter/material.dart';

class JilidDetailPage extends StatefulWidget {
  final Map<String, dynamic> jilid;

  const JilidDetailPage({super.key, required this.jilid});

  @override
  State<JilidDetailPage> createState() => _JilidDetailPageState();
}

class _JilidDetailPageState extends State<JilidDetailPage> {
  late List<Map<String, dynamic>> _lembarList;

  @override
  void initState() {
    super.initState();
    // Initialize lembar list from jilid data
    _lembarList = List<Map<String, dynamic>>.from(widget.jilid['lembar'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _saveAndReturn,
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.jilid['title'] ?? 'Jilid',
                              style: theme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_lembarList.length} artikel',
                              style: theme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Description
              if (widget.jilid['description'] != null &&
                  (widget.jilid['description'] as String).isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.jilid['description'] as String,
                      style: theme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),

              const Divider(height: 1, color: Color(0xFFE6E6E6)),

              // List Lembar
              Expanded(
                child: _lembarList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada lembar dalam jilid ini',
                              style: theme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan lembar untuk memulai',
                              style: theme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        itemCount: _lembarList.length,
                        itemBuilder: (context, index) {
                          final lembar = _lembarList[index];
                          return _buildLembarCard(lembar, theme, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLembarCard(
    Map<String, dynamic> lembar,
    TextTheme theme,
    int index,
  ) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              // TODO: Navigate to lembar detail or blog page
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.article,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Main Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          lembar['title'] ?? 'Untitled',
                          style: theme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Snippet
                        Text(
                          lembar['snippet'] ?? '',
                          style: theme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (lembar['date'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            lembar['date'] as String,
                            style: theme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // No remove button in view mode
                ],
              ),
            ),
          ),
        ),
        // Divider
        const Divider(height: 1, thickness: 1, color: Color(0xFFDDDDDD)),
      ],
    );
  }

  // Removed _addLembar method - not needed in view mode

  Future<void> _saveAndReturn() async {
    // In view mode, just return without saving
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
