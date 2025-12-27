import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'package:flutter/gestures.dart';

class ProjectWorkspacePage extends StatefulWidget {
  final Project project;

  const ProjectWorkspacePage({super.key, required this.project});

  @override
  State<ProjectWorkspacePage> createState() => _ProjectWorkspacePageState();
}

class _ProjectWorkspacePageState extends State<ProjectWorkspacePage> {
  static const bg = Color(0xFF121212);
  static const panel = Color(0xFF1E1E1E);
  static const card = Color(0xFF242424);
  static const grey = Colors.grey;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool isViewMode = false;

  DateTime? lastSaved;

  late Article selectedArticle;

  final List<Article> articles = [];
  @override
  void initState() {
    super.initState();

    final sample = Article(
      id: "1",
      title: "Sample Article 1",
      category: "Sample category",
      content:
          "This is a sample article created to demonstrate the structure and tone of a basic piece of writing.\n\n"
          "link to another article\n\n"
          "Overall, this article exists only as a model.",
      createdAt: DateTime.now(),
    );

    articles.add(sample);
    selectedArticle = sample;
    _loadArticle(selectedArticle);
  }

  void _openArticleByTitle(String title) {
    final match = articles.firstWhere(
      (a) => a.title == title,
      orElse: () => selectedArticle,
    );

    setState(() {
      selectedArticle = match;
      _loadArticle(selectedArticle);
    });
  }

  void _wrapSelection(String before, String after) {
    final text = contentController.text;
    final selection = contentController.selection;

    if (!selection.isValid || selection.isCollapsed) return;

    final selected = text.substring(selection.start, selection.end);

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      "$before$selected$after",
    );

    contentController.text = newText;

    contentController.selection = TextSelection(
      baseOffset: selection.start + before.length,
      extentOffset: selection.start + before.length + selected.length,
    );
  }

  void _insertBlock(String prefix) {
    final text = contentController.text;
    final selection = contentController.selection;

    final start = selection.start;
    final lineStart = text.lastIndexOf('\n', start - 1) + 1;

    final newText = text.replaceRange(lineStart, lineStart, prefix);

    contentController.text = newText;

    contentController.selection = TextSelection.collapsed(
      offset: start + prefix.length,
    );
  }

  void _saveArticle() {
    setState(() {
      selectedArticle.title = titleController.text.trim();
      selectedArticle.content = contentController.text;
      lastSaved = DateTime.now();
    });
  }

  void _loadArticle(Article article) {
    titleController.text = article.title;
    contentController.text = article.content;
  }

  void _showNewArticleDialog() {
    final titleController = TextEditingController();
    String category = "Uncategorized";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: panel,
          title: const Text(
            "New Article",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Article Title",
                    labelStyle: TextStyle(color: grey),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: panel,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    labelStyle: TextStyle(color: grey),
                  ),
                  items: ["Uncategorized", "Sample category"]
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                final article = Article(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  category: category,
                  content: "",
                  createdAt: DateTime.now(),
                );

                setState(() {
                  articles.add(article);
                  selectedArticle = article;
                  _loadArticle(selectedArticle);
                });

                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          /// -------- TOP TAB BAR --------
          Container(
            height: 48,
            color: panel,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.home, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  widget.project.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 24),
                _articleTab(selectedArticle.title),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isViewMode ? Icons.edit : Icons.visibility,
                    color: Colors.white,
                  ),
                  tooltip: isViewMode ? "Edit mode" : "View mode",
                  onPressed: () {
                    setState(() {
                      isViewMode = !isViewMode;
                    });
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveArticle,
          ),

          /// -------- MAIN AREA --------
          Expanded(
            child: Row(
              children: [
                /// LEFT SIDEBAR
                Container(
                  width: 260,
                  color: panel,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.project.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Project Workspace",
                        style: TextStyle(color: grey, fontSize: 12),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search articles...",
                          hintStyle: const TextStyle(color: grey),
                          filled: true,
                          fillColor: card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        onPressed: _showNewArticleDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("New Article"),
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: grey),

                      const Text("ARTICLES", style: TextStyle(color: grey)),

                      const SizedBox(height: 8),

                      Expanded(
                        child: ListView(
                          children: articles.map((article) {
                            return ListTile(
                              title: Text(
                                article.title,
                                style: TextStyle(
                                  color: article == selectedArticle
                                      ? Colors.white
                                      : grey,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedArticle = article;
                                  _loadArticle(selectedArticle);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                /// MAIN ARTICLE AREA
                Expanded(
                  child: Container(
                    color: bg,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Article title",
                            hintStyle: TextStyle(color: grey),
                          ),
                        ),

                        const SizedBox(height: 4),
                        const Text(
                          "Sample category",
                          style: TextStyle(color: grey),
                        ),

                        const SizedBox(height: 24),
                        const SizedBox(height: 16),

                        // TOOLBAR (correct position)
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: panel,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _toolBtn("H", () => _insertBlock("## ")),
                                _toolBtn("B", () => _wrapSelection("**", "**")),
                                _toolBtn("I", () => _wrapSelection("_", "_")),
                                _toolBtn("U", () => _wrapSelection("__", "__")),
                                _toolBtn("S", () => _wrapSelection("~~", "~~")),
                                _toolBtn("X²", () => _wrapSelection("^", "^")),
                                _toolBtn("X₂", () => _wrapSelection("~", "~")),

                                _divider(),

                                _iconBtn(
                                  Icons.format_align_left,
                                  () => _insertBlock("[align:left]\n"),
                                ),
                                _iconBtn(
                                  Icons.format_align_center,
                                  () => _insertBlock("[align:center]\n"),
                                ),
                                _iconBtn(
                                  Icons.format_align_right,
                                  () => _insertBlock("[align:right]\n"),
                                ),
                                _iconBtn(
                                  Icons.format_align_justify,
                                  () => _insertBlock("[align:justify]\n"),
                                ),

                                _divider(),

                                _iconBtn(
                                  Icons.link,
                                  () => _wrapSelection("[[", "]]"),
                                ),
                                _iconBtn(Icons.cloud_upload, () {}),
                                _iconBtn(Icons.flag, () {}),

                                _divider(),

                                _iconBtn(Icons.list, () {}),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Expanded(
                          child: isViewMode
                              ? _buildViewMode()
                              : _buildEditMode(),
                        ),
                      ],
                    ),
                  ),
                ),

                /// INFOBOX PANEL
                /// INFOBOX PANEL
                Container(
                  width: 300,
                  color: panel,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              "SAMPLE",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _infoRow("left column", "right column"),
                        _infoRow("with", "<--- separator"),
                        _infoRow("centered", ""),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// FOOTER
          Container(
            height: 36,
            color: panel,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("T 744 words", style: TextStyle(color: grey)),
                Text("Last saved: 12:39:36 PM", style: TextStyle(color: grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _articleTab(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(title, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildViewMode() {
    return SingleChildScrollView(
      child: _renderFormattedText(contentController.text),
    );
  }

  Widget _buildEditMode() {
    return TextField(
      controller: contentController,
      expands: true,
      maxLines: null,
      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
      decoration: const InputDecoration(
        hintText: "Start writing your article...",
        hintStyle: TextStyle(color: grey),
        border: InputBorder.none,
      ),
    );
  }

  Widget _renderFormattedText(String text) {
    final lines = text.split('\n');

    TextAlign currentAlign = TextAlign.left;
    final widgets = <Widget>[];

    for (final line in lines) {
      // 1️⃣ Detect alignment markers
      if (line.startsWith("[align:")) {
        if (line.contains("center")) {
          currentAlign = TextAlign.center;
        } else if (line.contains("right")) {
          currentAlign = TextAlign.right;
        } else if (line.contains("justify")) {
          currentAlign = TextAlign.justify;
        } else {
          currentAlign = TextAlign.left;
        }
        continue; // ❗ do not render marker
      }

      // 2️⃣ Headings
      if (line.startsWith("## ")) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              line.substring(3),
              textAlign: currentAlign,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      // 3️⃣ Normal paragraphs
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            width: double.infinity, // 🔑 THIS IS THE FIX
            child: _inlineFormattedText(line, align: currentAlign),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _inlineFormattedText(String text, {TextAlign align = TextAlign.left}) {
    final spans = <InlineSpan>[];

    final regex = RegExp(
      r'(\*\*.*?\*\*|_.*?_|(\^.*?\^)|(~.*?~)|(\[\[.*?\]\]))',
    );

    final matches = regex.allMatches(text);

    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final token = match.group(0)!;

      // BOLD
      if (token.startsWith("**")) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      // ITALIC
      else if (token.startsWith("_")) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      // SUPERSCRIPT
      else if (token.startsWith("^")) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: Text(
                token.substring(1, token.length - 1),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        );
      }
      // SUBSCRIPT
      else if (token.startsWith("~")) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.bottom,
            child: Transform.translate(
              offset: const Offset(0, 4),
              child: Text(
                token.substring(1, token.length - 1),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
        );
      }
      // LINK [[Article Title]]
      else if (token.startsWith("[[")) {
        final articleTitle = token.substring(2, token.length - 2);

        spans.add(
          TextSpan(
            text: articleTitle,
            style: const TextStyle(
              color: Colors.lightBlueAccent,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _openArticleByTitle(articleTitle);
              },
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      textAlign: align,
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
        children: spans,
      ),
    );
  }

  Widget _infoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(left, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: Text(right, style: const TextStyle(color: grey)),
          ),
        ],
      ),
    );
  }
}

Widget _toolBtn(String text, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget _iconBtn(IconData icon, VoidCallback onTap) {
  return IconButton(
    icon: Icon(icon, color: Colors.white, size: 18),
    onPressed: onTap,
  );
}

Widget _divider() {
  return Container(
    width: 1,
    height: 24,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    color: Colors.grey.shade700,
  );
}

class Article {
  final String id;
  String title;
  String category;
  String content;
  DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.createdAt,
  });
}
