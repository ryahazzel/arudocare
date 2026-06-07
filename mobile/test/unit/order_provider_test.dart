import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:arudocare_app/features/order/providers/order_provider.dart';
import 'package:arudocare_app/features/home/models/product_model.dart';
import 'package:arudocare_app/core/api/api_client.dart';

const _testProduct = ProductModel(
  id: '10',
  name: 'Nasi Padang',
  merchantName: 'Warung Minang',
  merchantId: 5,
  originalPrice: 25000,
  discountPrice: 15000,
  stock: 10,
  category: 'Makanan',
  distanceKm: 1.0,
);

void main() {
  group('OrderProvider', () {
    late OrderProvider orderProvider;
    late DioAdapter dioAdapter;
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient();
      dioAdapter = DioAdapter(dio: apiClient.dio);
      orderProvider = OrderProvider(apiClient: apiClient);
    });

    tearDown(() {
      dioAdapter.close();
    });

    group('initial state', () {
      test('isLoading bernilai false', () {
        expect(orderProvider.isLoading, false);
      });

      test('error bernilai null', () {
        expect(orderProvider.error, isNull);
      });

      test('lastOrder bernilai null', () {
        expect(orderProvider.lastOrder, isNull);
      });

      test('activeOrders kosong', () {
        expect(orderProvider.activeOrders, isEmpty);
      });

      test('completedOrders kosong', () {
        expect(orderProvider.completedOrders, isEmpty);
      });
    });

    group('fetchUserOrders', () {
      test('activeOrders hanya berisi pesanan berstatus pending', () async {
        dioAdapter.onGet(
          '${ApiClient.baseUrl}/orders/user/1',
          (server) => server.reply(200, [
            {'id': 1, 'status': 'pending', 'product_name': 'Nasi'},
            {'id': 2, 'status': 'completed', 'product_name': 'Ayam'},
            {'id': 3, 'status': 'pending', 'product_name': 'Mie'},
          ]),
        );

        await orderProvider.fetchUserOrders(1);

        expect(orderProvider.activeOrders.length, 2);
        expect(orderProvider.activeOrders.every((o) => o['status'] == 'pending'), true);
      });

      test('completedOrders hanya berisi pesanan berstatus completed', () async {
        dioAdapter.onGet(
          '${ApiClient.baseUrl}/orders/user/2',
          (server) => server.reply(200, [
            {'id': 1, 'status': 'pending', 'product_name': 'Nasi'},
            {'id': 2, 'status': 'completed', 'product_name': 'Ayam'},
            {'id': 3, 'status': 'completed', 'product_name': 'Ikan'},
          ]),
        );

        await orderProvider.fetchUserOrders(2);

        expect(orderProvider.completedOrders.length, 2);
        expect(orderProvider.completedOrders.every((o) => o['status'] == 'completed'), true);
      });

      test('isLoading kembali false setelah fetch selesai', () async {
        dioAdapter.onGet(
          '${ApiClient.baseUrl}/orders/user/3',
          (server) => server.reply(200, []),
        );

        await orderProvider.fetchUserOrders(3);

        expect(orderProvider.isLoading, false);
      });
    });

    group('createOrder', () {
      test('menghitung total harga dengan benar (discountPrice x quantity)', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/orders',
          (server) => server.reply(201, {
            'order': {
              'id': 100,
              'status': 'pending',
              'product_name': 'Nasi Padang',
              'merchant_name': 'Warung Minang',
              'quantity': 2,
              'total_price': 30000.0,
              'qr_code': 'QR-100',
              'created_at': '2026-06-07T00:00:00.000Z',
            },
          }),
        );

        await orderProvider.createOrder(
          userId: 1,
          product: _testProduct,
          quantity: 2,
          paymentMethod: 'cash',
        );

        // discountPrice (15000) x quantity (2) = 30000
        expect(orderProvider.lastOrder?['total_price'], 30000);
      });

      test('mengembalikan true dan menyimpan lastOrder saat berhasil', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/orders',
          (server) => server.reply(201, {
            'order': {
              'id': 101,
              'status': 'pending',
              'product_name': 'Nasi Padang',
              'merchant_name': 'Warung Minang',
              'quantity': 1,
              'total_price': 15000.0,
              'qr_code': 'QR-101',
            },
          }),
        );

        final result = await orderProvider.createOrder(
          userId: 1,
          product: _testProduct,
          quantity: 1,
          paymentMethod: 'cash',
        );

        expect(result, true);
        expect(orderProvider.lastOrder, isNotNull);
        expect(orderProvider.lastOrder?['id'], 101);
        expect(orderProvider.isLoading, false);
      });

      test('pesanan baru muncul di activeOrders setelah dibuat', () async {
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/orders',
          (server) => server.reply(201, {
            'order': {
              'id': 102,
              'status': 'pending',
              'product_name': 'Nasi Padang',
              'quantity': 1,
              'total_price': 15000.0,
              'qr_code': 'QR-102',
            },
          }),
        );

        await orderProvider.createOrder(
          userId: 1,
          product: _testProduct,
          quantity: 1,
          paymentMethod: 'cash',
        );

        expect(orderProvider.activeOrders.length, 1);
        expect(orderProvider.activeOrders.first['status'], 'pending');
      });

      test('fallback ke demo order saat terjadi DioException', () async {
        // Tidak ada mock = DioException (route tidak ditemukan)
        dioAdapter.onPost(
          '${ApiClient.baseUrl}/orders',
          (server) => server.throws(
            500,
            DioException(
              requestOptions: RequestOptions(path: '/orders'),
              type: DioExceptionType.badResponse,
            ),
          ),
        );

        final result = await orderProvider.createOrder(
          userId: 1,
          product: _testProduct,
          quantity: 3,
          paymentMethod: 'cash',
        );

        // Provider membuat demo order sebagai fallback
        expect(result, true);
        expect(orderProvider.lastOrder, isNotNull);
        expect(orderProvider.lastOrder?['product_name'], 'Nasi Padang');
        expect(orderProvider.lastOrder?['total_price'], 45000.0); // 15000 x 3
        expect(orderProvider.lastOrder?['status'], 'pending');
        expect(orderProvider.isLoading, false);
      });
    });
  });
}
