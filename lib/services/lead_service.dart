import '../models/lead_models.dart';

class LeadService {
  static final List<Lead> _leads = [];

  // Get all leads
  static List<Lead> getLeads() {
    return List.from(_leads);
  }

  // Add a new lead
  static Future<bool> addLead(Lead lead) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate ID if not provided
      final newLead = lead.copyWith(
        id: lead.id ?? 'lead_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        status: 'active',
      );
      
      _leads.add(newLead);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update an existing lead
  static Future<bool> updateLead(Lead lead) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _leads.indexWhere((l) => l.id == lead.id);
      if (index != -1) {
        _leads[index] = lead;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Delete a lead
  static Future<bool> deleteLead(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _leads.indexWhere((l) => l.id == id);
      if (index != -1) {
        _leads.removeAt(index);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get lead by ID
  static Lead? getLeadById(String id) {
    try {
      return _leads.firstWhere((lead) => lead.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search leads by name or phone
  static List<Lead> searchLeads(String query) {
    if (query.isEmpty) return getLeads();
    
    final lowercaseQuery = query.toLowerCase();
    return _leads.where((lead) {
      return lead.name.toLowerCase().contains(lowercaseQuery) ||
             lead.phone.contains(query) ||
             (lead.divisionName?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Validate phone number
  static bool validatePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 15;
  }

  // Format phone number for display
  static String formatPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  // Get leads count
  static int getLeadsCount() {
    return _leads.length;
  }

  // Clear all leads (for testing)
  static void clearLeads() {
    _leads.clear();
  }
}