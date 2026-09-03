import 'dart:async';
import 'package:flutter/material.dart';
import '../supabase.dart';

/// شاشة البحث الشامل — خدمات + مدن + فنادق من Supabase
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;

  // كتالوج خدمات التطبيق
  static const List<Map<String, dynamic>> _services = [
    {
      'icon': Icons.hotel,
      'title': 'فنادق',
      'desc': 'احجز أفضل الفنادق في كل المحافظات',
    },
    {
      'icon': Icons.directions_car,
      'title': 'تأجير سيارات',
      'desc': 'سيارات حديثة بسائق أو بدون سائق',
    },
    {
      'icon': Icons.local_taxi,
      'title': 'نقل مع سائق',
      'desc': 'رحلات خاصة ومريحة بين المدن',
    },
    {
      'icon': Icons.card_giftcard,
      'title': 'باقات أسبوعية',
      'desc': 'فندق + سيارة بأسعار وعروض خاصة',
    },
    {
      'icon': Icons.directions_boat,
      'title': 'رحلات بحرية',
      'desc': 'جولات بحرية وجزر سياحية ساحرة',
    },
    {
      'icon': Icons.flight_land,
      'title': 'نقل المطار',
      'desc': 'استقبال وتوصيل من وإلى المطارات',
    },
  ];

  static const List<String> _cities = [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'المكلا',
    'سيئون',
    'سقطرى',
    'ذمار',
    'لحج',
    'حضرموت',
    'عمران',
    'صعدة',
    'شبوة',
  ];

  List<Map<String, dynamic>> _serviceResults = [];
  List<String> _cityResults = [];
  List<Map<String, dynamic>> _hotels = [];
  bool _hotelsLoading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _ctrl.text.trim();
    if (!mounted) return;
    setState(() => _query = q);

    if (q.isEmpty) {
      setState(() {
        _serviceResults = [];
        _cityResults = [];
        _hotels = [];
        _hotelsLoading = false;
      });
      return;
    }

    final ql = q.toLowerCase();

    _serviceResults = _services
        .where((s) =>
            (s['title'] as String).contains(q) ||
            (s['desc'] as String).contains(q))
        .toList();

    _cityResults = _cities
        .where((c) => c.contains(q) || c.toLowerCase().contains(ql))
        .toList();

    setState(() => _hotelsLoading = true);
    try {
      final res = await supabase
          .from('hotels')
          .select()
          .ilike('name', '%$q%')
          .limit(20);
      _hotels = List<Map<String, dynamic>>.from(res);
    } catch (_) {
      _hotels = [];
    }
    if (!mounted) return;
    setState(() => _hotelsLoading = false);
  }

  void _openDetails({
    required String title,
    required String desc,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Theme.of(ctx).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900)),
              ),
            ]),
            const SizedBox(height: 12),
            Text(desc),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('حسناً'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.isNotEmpty;
    final noResults = hasQuery &&
        _serviceResults.isEmpty &&
        _cityResults.isEmpty &&
        _hotels.isEmpty &&
        !_hotelsLoading;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث عن فنادق، مدن، خدمات...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                _runSearch();
              },
            ),
        ],
      ),
      body: !hasQuery ? _buildHints() : _buildResults(noResults),
    );
  }

  Widget _buildHints() {
    const chips = ['فنادق', 'عدن', 'سيارات', 'باقات', 'رحلات بحرية'];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('اقتراحات سريعة',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips
              .map((c) => ActionChip(
                    label: Text(c),
                    onPressed: () {
                      _ctrl.text = c;
                      _runSearch();
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(t,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildResults(bool noResults) {
    if (noResults) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('لا توجد نتائج مطابقة لبحثك'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_hotelsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),

        if (_serviceResults.isNotEmpty) ...[
          _sectionTitle('الخدمات'),
          ..._serviceResults.map((s) => Card(
                child: ListTile(
                  leading: Icon(s['icon'] as IconData,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(s['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(s['desc'] as String,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => _openDetails(
                    title: s['title'] as String,
                    desc: s['desc'] as String,
                    icon: s['icon'] as IconData,
                  ),
                ),
              )),
        ],

        if (_cityResults.isNotEmpty) ...[
          _sectionTitle('المدن'),
          ..._cityResults.map((c) => Card(
                child: ListTile(
                  leading: Icon(Icons.location_city,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(c,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('استكشف الخدمات المتاحة في هذه المدينة'),
                  onTap: () => _openDetails(
                    title: c,
                    desc: 'استكشف خدمات $c: فنادق، سيارات، رحلات بحرية وأكثر.',
                    icon: Icons.location_city,
                  ),
                ),
              )),
        ],

        if (_hotels.isNotEmpty) ...[
          _sectionTitle('فنادق (نتائج مباشرة)'),
          ..._hotels.map((h) => Card(
                child: ListTile(
                  leading: Icon(Icons.hotel,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text(
                    (h['name'] ?? 'فندق').toString(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    'الموقع: ${(h['city'] ?? 'غير محدد')} • السعر: ${(h['price_per_night'] ?? '—')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openDetails(
                    title: (h['name'] ?? 'فندق').toString(),
                    desc: 'الموقع: ${(h['city'] ?? 'غير محدد')}\n'
                        'السعر: ${(h['price_per_night'] ?? '—')}',
                    icon: Icons.hotel,
                  ),
                ),
              )),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }
}
