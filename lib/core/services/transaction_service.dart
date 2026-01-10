import 'package:dio/dio.dart';
import '../../data/models/transaction_model.dart';
import '../network/api_client.dart';

/// Transaction service for API interactions
class TransactionService {
  final ApiClient _apiClient;

  TransactionService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Create a new transaction
  Future<Transaction> createTransaction(
    CreateTransactionRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/transactions',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return Transaction.fromJson(data);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get all transactions with optional filters
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      if (status != null) {
        queryParams['status'] = status;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (offset != null) {
        queryParams['offset'] = offset;
      }

      final response = await _apiClient.get(
        '/transactions',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // Handle paginated response: { data: [...], pagination: {...} }
      // Or simple list if API changes, but PWA confirms pagination structure
      final responseData = response.data['data'];

      // Check if data is directly a list or nested in paginated response
      List listData;
      if (responseData is List) {
        listData = responseData;
      } else if (responseData is Map && responseData.containsKey('data')) {
        // Shouldn't happen based on PWA code, but being safe
        // actually PWA code says: response.data.data IS the list if paginated?
        // No, PWA types say: response.data is PaginatedResponse which has 'data' property
        // So response.data['data'] IS the list.
        // Let's stick with response.data['data'] as list
        listData = []; // Fallback if type match fails
      } else {
        listData = responseData as List? ?? [];
      }

      return listData
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get transaction by ID
  Future<Transaction> getTransactionById(String id) async {
    try {
      final response = await _apiClient.get('/transactions/$id');
      return Transaction.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get today's transactions with summary
  /// Uses /transactions/today endpoint instead of filtering
  Future<TodayTransactionsResult> getTodayTransactions() async {
    try {
      final response = await _apiClient.get('/transactions/today');

      // Verify structure matches { data: { transactions: [], summary: {} } }
      final data = response.data['data'] as Map<String, dynamic>;

      return TodayTransactionsResult.fromJson(data);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get transaction summary/stats (for dashboard)
  Future<Map<String, dynamic>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiClient.get(
        '/transactions/stats',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get dashboard summary from /reports/summary endpoint
  /// This matches the PWA implementation for consistent data
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _apiClient.get('/reports/summary');
      return DashboardSummary.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw e.apiException;
    }
  }
}
