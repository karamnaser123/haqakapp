import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../core/models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.orderDetails} #${order.id}',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[800]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildOrderStatusCard(context),
              const SizedBox(height: 16),
              _buildOrderInfoCard(context),
              const SizedBox(height: 16),
              _buildOrderItemsCard(context),
              const SizedBox(height: 16),
              _buildPaymentInfoCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final statusIcon = _getStatusIcon(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            statusIcon,
            size: 48,
            color: statusColor,
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusText(order.status, context),
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusDescription(order.status, context),
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.orderInformation,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.shopping_bag,
            AppLocalizations.of(context)!.orderNumber,
            '#${order.id}',
          ),
          _buildInfoRow(
            context,
            Icons.calendar_today,
            AppLocalizations.of(context)!.orderDate,
            _formatDate(order.createdAt),
          ),
          _buildInfoRow(
            context,
            Icons.store,
            AppLocalizations.of(context)!.storeName,
            order.store.name,
          ),
          _buildInfoRow(
            context,
            Icons.shopping_cart,
            AppLocalizations.of(context)!.orderItems,
            '${order.quantity} ${order.quantity == 1 ? AppLocalizations.of(context)!.item : AppLocalizations.of(context)!.items}',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.orderItems,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          ...order.orderItems.map((item) => _buildOrderItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? item.product.nameAr : item.product.nameEn,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.quantity}: ${item.quantity}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.totalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.paymentAndDeliveryInfo,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            Icons.location_on,
            AppLocalizations.of(context)!.deliveryAddress,
            order.address,
          ),
          _buildInfoRow(
            context,
            Icons.phone,
            AppLocalizations.of(context)!.phoneNumber,
            order.phone,
          ),
          _buildInfoRow(
            context,
            Icons.payment,
            AppLocalizations.of(context)!.paymentMethod,
            _getPaymentMethodText(order.paymentMethod, context),
          ),
          const Divider(height: 24),
          // Price breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.subtotal}:',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${order.subtotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.discount}:',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                ),
                Text(
                  '-${order.discountAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
          if (order.deliveryFee > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.deliveryFee}:',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${order.deliveryFee.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.finalTotal}:',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              Text(
                '${order.totalPrice.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          if (order.cashbackAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${AppLocalizations.of(context)!.cashbackEarned}: +${order.cashbackAmount.toStringAsFixed(2)} ${AppLocalizations.of(context)!.jd}',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.settings;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppLocalizations.of(context)!.orderStatusPending;
      case 'processing':
        return AppLocalizations.of(context)!.orderStatusProcessing;
      case 'shipped':
        return AppLocalizations.of(context)!.orderStatusShipped;
      case 'delivered':
        return AppLocalizations.of(context)!.orderStatusDelivered;
      case 'completed':
        return AppLocalizations.of(context)!.orderStatusCompleted;
      case 'cancelled':
        return AppLocalizations.of(context)!.orderStatusCancelled;
      default:
        return AppLocalizations.of(context)!.unknownStatus;
    }
  }

  String _getStatusDescription(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppLocalizations.of(context)!.orderStatusPending;
      case 'processing':
        return AppLocalizations.of(context)!.orderStatusProcessing;
      case 'shipped':
        return AppLocalizations.of(context)!.orderStatusShipped;
      case 'delivered':
        return AppLocalizations.of(context)!.orderStatusDelivered;
      case 'completed':
        return AppLocalizations.of(context)!.orderStatusCompleted;
      case 'cancelled':
        return AppLocalizations.of(context)!.orderStatusCancelled;
      default:
        return AppLocalizations.of(context)!.unknownStatus;
    }
  }

  String _getPaymentMethodText(String paymentMethod, BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return AppLocalizations.of(context)!.cash;
      case 'card':
        return AppLocalizations.of(context)!.creditCard;
      case 'bank_transfer':
        return AppLocalizations.of(context)!.bankTransfer;
      default:
        return paymentMethod;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
