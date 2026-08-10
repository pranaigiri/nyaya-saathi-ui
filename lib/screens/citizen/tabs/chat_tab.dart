import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../models/chat_message_model.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final _msgController = TextEditingController();
  List<ChatMessageModel> _messages = [];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Who is eligible for free Legal Aid in Sikkim?',
      'a': 'Under Section 12 of the Legal Services Authorities Act, 1987, women, children, SC/ST members, victims of disasters, mentally ill/disabled persons, and citizens with annual income < ₹3,00,000 are eligible.'
    },
    {
      'q': 'How long does application processing take?',
      'a': 'Initial scrutiny by DLSA is completed within 3-5 working days. Upon approval, an advocate is assigned immediately.'
    },
    {
      'q': 'Can I apply on behalf of someone else?',
      'a': 'Yes! Select "Other" under "Applying For" in Step 2 and mention your relation to the applicant.'
    },
    {
      'q': 'Are legal aid services 100% free?',
      'a': 'Yes, all services including advocate representation, court fees, and paper filing provided by SLSA are completely free.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    final msgs = await SupabaseService().getChatMessages();
    setState(() => _messages = msgs);
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();

    SupabaseService().addChatMessage(text);
    _loadMessages();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _loadMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: const TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondaryLight,
              indicatorColor: AppColors.primaryBlue,
              tabs: [
                Tab(text: "FAQ Support"),
                Tab(text: "Authority Messages"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // FAQ Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _faqs.length,
                  itemBuilder: (context, index) {
                    final item = _faqs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: ExpansionTile(
                          leading: const Icon(Icons.help_outline, color: AppColors.primaryBlue),
                          title: Text(item['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                item['a']!,
                                style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Interactive Authority Messages Tab
                Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isAuth = msg.isFromAuthority;
                          return Align(
                            alignment: isAuth ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isAuth ? AppColors.primaryBlue : AppColors.accentGold,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAuth ? "DLSA Official Authority" : "You",
                                    style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg.message,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              decoration: const InputDecoration(
                                hintText: "Ask authority a question...",
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppColors.primaryBlue),
                            onPressed: _sendMessage,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
