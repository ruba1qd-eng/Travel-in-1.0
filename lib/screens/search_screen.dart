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

    // البحث في كتالوج الخدمات
    _serviceResults = _services
        .where((s) =>
            (s['title'] as String).contains(q) ||
            (s['desc'] as String).contains(q))
        .toList();

    // البحث في المدن
    _cityResults = _cities
        .where((c) => c.contains(q) || c.toLowerCase().contains(ql))
        .toList();

    // البحث في فنادق Supabase — بأمان وبدون انهيار
    setState(() => _hotelsLoading = true);
    try {
      final res = await supabase.from('hotels').select().limit(50);
      final all = List<Map<String, dynamic>>.from(res);
      // فلترة محلياً — تعمل مع أي اسم عمود
      _hotels = all.where((h) {
        final name = (h['name'] ?? h['title'] ?? '').toString().toLowerCase();
        final city = (h['city'] ?? h['location'] ?? '').toString().toLowerCase();
        return name.contains(ql) || city.contains(ql);
      }).take(20).toList();
    } catch (_) {
      _hotels = [];
    }
    if (!mounted) return;
    setState(() => _hotelsLoading = false);
  }
