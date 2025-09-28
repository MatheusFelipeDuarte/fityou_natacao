import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/responsive.dart';
import '../students/students_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentsPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Falha ao entrar');
    } catch (e) {
      setState(() => _error = 'Erro inesperado');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final padding = EdgeInsets.all(Responsive.responsivePadding(context));

    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 480 : 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Acesso restrito', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      Text('Somente usuários cadastrados pelo administrador.', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Senha'),
                        obscureText: true,
                        validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _busy ? null : _signIn,
                        child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Entrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
