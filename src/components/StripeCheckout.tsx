import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CreditCard, Lock, CheckCircle, AlertCircle, Loader2 } from 'lucide-react';
import { orderService, enrollmentService } from '../services';

interface StripeCheckoutProps {
  courseId: string;
  courseTitle: string;
  price: number;
  onSuccess: () => void;
  onCancel: () => void;
}

export default function StripeCheckout({ courseId, courseTitle, price, onSuccess, onCancel }: StripeCheckoutProps) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [step, setStep] = useState<'form' | 'processing' | 'success'>('form');
  const [cardDetails, setCardDetails] = useState({
    cardNumber: '',
    expiry: '',
    cvc: '',
    name: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    setStep('processing');

    // Simulate Stripe payment processing
    await new Promise((resolve) => setTimeout(resolve, 2000));

    try {
      // In production, this would call a Supabase Edge Function or your backend
      // that creates a Stripe PaymentIntent and confirms the payment
      const orderNumber = `OP-${Date.now()}`;

      const orderResult = await orderService.createOrder({
        order_number: orderNumber,
        total: price,
        total_amount: price,
        currency: 'USD',
        payment_method: 'Credit Card',
        payment_provider: 'stripe',
        status: 'completed',
        items: [{ course_id: courseId, course_title: courseTitle, price }],
      });

      if (orderResult.error) throw new Error(orderResult.error.message);

      const enrollResult = await enrollmentService.createEnrollment(
        '', // userId is handled by RLS / auth context
        courseId,
        'active'
      );

      if (enrollResult.error) throw new Error(enrollResult.error.message);

      setStep('success');
      setTimeout(() => onSuccess(), 1500);
    } catch (err: any) {
      setError(err.message || 'Payment failed. Please try again.');
      setStep('form');
    } finally {
      setLoading(false);
    }
  };

  const formatCardNumber = (value: string) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    const parts = [];
    for (let i = 0; i < v.length; i += 4) {
      parts.push(v.substring(i, i + 4));
    }
    return parts.join(' ').substring(0, 19);
  };

  const formatExpiry = (value: string) => {
    const v = value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
    if (v.length >= 2) {
      return `${v.substring(0, 2)}/${v.substring(2, 4)}`;
    }
    return v;
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="bg-dark-card border border-dark-border rounded-xl w-full max-w-md overflow-hidden"
      >
        {/* Header */}
        <div className="p-6 border-b border-dark-border">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <CreditCard className="w-5 h-5 text-oracle-red" />
              <h3 className="text-white font-semibold">Secure Checkout</h3>
            </div>
            <button onClick={onCancel} className="text-dark-muted hover:text-white transition-colors">
              <Lock className="w-4 h-4" />
            </button>
          </div>
          <div className="mt-3 flex items-baseline gap-2">
            <span className="text-2xl font-bold text-white">${price}</span>
            <span className="text-dark-muted text-sm">USD</span>
          </div>
          <p className="text-dark-muted text-sm mt-1">{courseTitle}</p>
        </div>

        <AnimatePresence mode="wait">
          {step === 'form' && (
            <motion.div
              key="form"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="p-6"
            >
              {error && (
                <div className="mb-4 p-3 rounded-lg bg-red-500/10 border border-red-500/20 flex items-start gap-2">
                  <AlertCircle className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                  <p className="text-red-400 text-sm">{error}</p>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm text-white mb-1.5">Cardholder Name</label>
                  <input
                    type="text"
                    value={cardDetails.name}
                    onChange={(e) => setCardDetails({ ...cardDetails, name: e.target.value })}
                    required
                    placeholder="John Doe"
                    className="w-full px-4 py-3 rounded-lg bg-dark-surface border border-dark-border text-white placeholder-dark-muted focus:outline-none focus:border-oracle-red/50 transition-colors"
                  />
                </div>

                <div>
                  <label className="block text-sm text-white mb-1.5">Card Number</label>
                  <div className="relative">
                    <CreditCard className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-dark-muted" />
                    <input
                      type="text"
                      value={cardDetails.cardNumber}
                      onChange={(e) => setCardDetails({ ...cardDetails, cardNumber: formatCardNumber(e.target.value) })}
                      required
                      maxLength={19}
                      placeholder="4242 4242 4242 4242"
                      className="w-full pl-10 pr-4 py-3 rounded-lg bg-dark-surface border border-dark-border text-white placeholder-dark-muted focus:outline-none focus:border-oracle-red/50 transition-colors font-mono"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm text-white mb-1.5">Expiry</label>
                    <input
                      type="text"
                      value={cardDetails.expiry}
                      onChange={(e) => setCardDetails({ ...cardDetails, expiry: formatExpiry(e.target.value) })}
                      required
                      maxLength={5}
                      placeholder="MM/YY"
                      className="w-full px-4 py-3 rounded-lg bg-dark-surface border border-dark-border text-white placeholder-dark-muted focus:outline-none focus:border-oracle-red/50 transition-colors font-mono"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-white mb-1.5">CVC</label>
                    <input
                      type="text"
                      value={cardDetails.cvc}
                      onChange={(e) => setCardDetails({ ...cardDetails, cvc: e.target.value.replace(/\D/g, '').substring(0, 4) })}
                      required
                      maxLength={4}
                      placeholder="123"
                      className="w-full px-4 py-3 rounded-lg bg-dark-surface border border-dark-border text-white placeholder-dark-muted focus:outline-none focus:border-oracle-red/50 transition-colors font-mono"
                    />
                  </div>
                </div>

                <div className="flex items-center gap-2 text-xs text-dark-muted">
                  <Lock className="w-3.5 h-3.5" />
                  Payments are encrypted and secure. PCI compliant.
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="w-full flex items-center justify-center gap-2 px-6 py-3 rounded-lg bg-oracle-red text-white font-semibold hover:bg-oracle-dark transition-colors disabled:opacity-50"
                >
                  {loading ? (
                    <Loader2 className="w-5 h-5 animate-spin" />
                  ) : (
                    <>
                      <Lock className="w-4 h-4" />
                      Pay ${price}
                    </>
                  )}
                </button>
              </form>

              <button
                onClick={onCancel}
                className="w-full mt-3 text-sm text-dark-muted hover:text-white transition-colors"
              >
                Cancel
              </button>
            </motion.div>
          )}

          {step === 'processing' && (
            <motion.div
              key="processing"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="p-12 text-center"
            >
              <Loader2 className="w-12 h-12 text-oracle-red animate-spin mx-auto mb-4" />
              <p className="text-white font-medium">Processing Payment...</p>
              <p className="text-dark-muted text-sm mt-1">Please do not close this window</p>
            </motion.div>
          )}

          {step === 'success' && (
            <motion.div
              key="success"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="p-12 text-center"
            >
              <CheckCircle className="w-12 h-12 text-green-500 mx-auto mb-4" />
              <p className="text-white font-medium">Payment Successful!</p>
              <p className="text-dark-muted text-sm mt-1">Redirecting to your course...</p>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
