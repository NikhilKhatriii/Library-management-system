import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/models/book.dart';
import '../../application/books_provider.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _copiesController = TextEditingController(text: '5');
  final _customCoverController = TextEditingController();

  String _selectedCoverUrl = _coverTemplates.first['url']!;
  String _selectedCategoryId = 'c1';
  String _selectedCategoryName = 'Fiction';

  static const List<Map<String, String>> _coverTemplates = [
    {
      'name': 'Fiction',
      'url': 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?q=80&w=400',
    },
    {
      'name': 'Tech',
      'url': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?q=80&w=400',
    },
    {
      'name': 'History',
      'url': 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?q=80&w=400',
    },
    {
      'name': 'Science',
      'url': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=400',
    },
    {
      'name': 'Philosophy',
      'url': 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?q=80&w=400',
    },
    {
      'name': 'Poetry',
      'url': 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?q=80&w=400',
    },
  ];

  final List<Map<String, String>> _categories = [
    {'id': 'c1', 'name': 'Fiction'},
    {'id': 'c2', 'name': 'Technology'},
    {'id': 'c3', 'name': 'History'},
    {'id': 'c4', 'name': 'Science'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _copiesController.dispose();
    _customCoverController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final author = _authorController.text.trim();
      final isbn = _isbnController.text.trim();
      final publisher = _publisherController.text.trim();
      final description = _descriptionController.text.trim();
      final copies = int.tryParse(_copiesController.text.trim()) ?? 5;
      final cover = _customCoverController.text.trim().isNotEmpty
          ? _customCoverController.text.trim()
          : _selectedCoverUrl;

      final bookId = DateTime.now().millisecondsSinceEpoch.toString();
      final newBook = Book(
        id: bookId,
        title: title,
        authorId: 'auth_${bookId.substring(6)}',
        authorName: author,
        isbn: isbn,
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        publisherId: 'pub_${bookId.substring(6)}',
        publisherName: publisher.isEmpty ? 'Unknown Publisher' : publisher,
        publishDate: DateTime.now(),
        description: description.isEmpty ? 'No description provided.' : description,
        coverUrl: cover,
        totalCopies: copies,
        availableCopies: copies,
        rating: 4.5,
      );

      final res = await ref.read(booksNotifierProvider.notifier).addBook(newBook);
      if (mounted) {
        if (res is Success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book added successfully')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add book: ${(res as Failure).message}')),
          );
        }
      }
    }
  }

  void _showScannerSim() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Icon(Icons.qr_code_scanner_rounded, size: 64, color: Colors.blue),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Simulating Barcode Scanner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Align barcode/QR code within the frame to automatically fill details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () {
                        final randomIsbn = (9780000000000 + (DateTime.now().millisecondsSinceEpoch % 10000000000)).toString();
                        _isbnController.text = randomIsbn;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detected ISBN: $randomIsbn')),
                        );
                      },
                      child: const Text('Simulate Scan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoverSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Choose Book Cover',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Select one of our premium book cover templates or paste your own cover URL.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _coverTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _coverTemplates[index];
                      final isSelected = _selectedCoverUrl == template['url'];
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _selectedCoverUrl = template['url']!;
                          });
                          setState(() {
                            _selectedCoverUrl = template['url']!;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: template['url']!,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: Text(
                                    template['name']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: const Icon(Icons.check, size: 14, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Or custom image URL',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _customCoverController,
                  decoration: InputDecoration(
                    hintText: 'https://images.unsplash.com/...',
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Done',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedCover = _customCoverController.text.trim().isNotEmpty
        ? _customCoverController.text.trim()
        : _selectedCoverUrl;

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showCoverSelector,
                  child: Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: displayedCover,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, err) => const Center(
                            child: Icon(Icons.broken_image_rounded, size: 40),
                          ),
                        ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 28, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                'Change Cover',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(delay: 100.ms, duration: 300.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Book Title',
                controller: _titleController,
                hint: 'e.g. The Great Gatsby',
                validator: (v) => v?.trim().isEmpty ?? true ? 'Book title is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Author',
                controller: _authorController,
                hint: 'e.g. F. Scott Fitzgerald',
                validator: (v) => v?.trim().isEmpty ?? true ? 'Author name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'ISBN',
                      controller: _isbnController,
                      hint: '13-digit ISBN',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'ISBN is required';
                        if (v.trim().length < 10) return 'Invalid ISBN format';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        minimumSize: const Size(52, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: _showScannerSim,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Category',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategoryId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.02),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 14,
                            ),
                          ),
                          items: _categories.map((c) {
                            return DropdownMenuItem<String>(
                              value: c['id'],
                              child: Text(c['name']!),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCategoryId = val;
                                _selectedCategoryName = _categories.firstWhere((c) => c['id'] == val)['name']!;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Total Copies',
                      controller: _copiesController,
                      hint: 'e.g. 5',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Copies required';
                        final numVal = int.tryParse(v.trim());
                        if (numVal == null || numVal < 1) return 'Must be >= 1';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Publisher',
                controller: _publisherController,
                hint: 'e.g. Scribner',
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Description',
                controller: _descriptionController,
                hint: 'Enter book synopsis...',
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Save Book',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
