import 'package:flutter/material.dart';
import 'package:flutter_chekmate/core/theme/app_colors.dart';
import 'package:flutter_chekmate/core/theme/app_spacing.dart';
import 'package:flutter_chekmate/features/search/data/repositories/search_repository_impl.dart';
import 'package:flutter_chekmate/features/search/domain/entities/search_result_entity.dart';

/// Tag People Bottom Sheet
/// Allows users to search and tag other users in their posts
class TagPeopleSheet extends StatefulWidget {
  const TagPeopleSheet({
    required this.onTagsChanged,
    this.initialTags = const [],
    super.key,
  });

  final List<TaggedUser> initialTags;
  final void Function(List<TaggedUser>) onTagsChanged;

  @override
  State<TagPeopleSheet> createState() => _TagPeopleSheetState();
}

class _TagPeopleSheetState extends State<TagPeopleSheet> {
  final TextEditingController _searchController = TextEditingController();
  final SearchRepositoryImpl _searchRepository = SearchRepositoryImpl();
  
  List<TaggedUser> _taggedUsers = [];
  List<SearchResultEntity> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _taggedUsers = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _searchRepository.searchUsers(
        query: query,
        limit: 20,
      );
      
      // Filter out already tagged users
      final taggedIds = _taggedUsers.map((u) => u.id).toSet();
      final filteredResults = results
          .where((r) => !taggedIds.contains(r.id))
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = filteredResults;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _addTag(SearchResultEntity user) {
    final taggedUser = TaggedUser(
      id: user.id,
      username: user.subtitle.replaceFirst('@', ''),
      displayName: user.title,
      avatarUrl: user.imageUrl,
    );

    setState(() {
      _taggedUsers.add(taggedUser);
      _searchResults = [];
      _searchController.clear();
    });

    widget.onTagsChanged(_taggedUsers);
  }

  void _removeTag(TaggedUser user) {
    setState(() {
      _taggedUsers.removeWhere((u) => u.id == user.id);
    });

    widget.onTagsChanged(_taggedUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tag People',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navyBlue,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for people...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchUsers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: _searchUsers,
          ),
          const SizedBox(height: AppSpacing.md),

          // Tagged users chips
          if (_taggedUsers.isNotEmpty) ...[
            const Text(
              'Tagged',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _taggedUsers.map((user) {
                return Chip(
                  avatar: user.avatarUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user.avatarUrl!),
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                        )
                      : CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(
                            user.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                  label: Text('@${user.username}'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeTag(user),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppColors.primary),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Search results
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return _buildUserTile(user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search for people to tag',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Type a name or username to find people',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No users found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(SearchResultEntity user) {
    final isVerified = user.metadata?['isVerified'] == true;
    final followers = user.metadata?['followers'] as int? ?? 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.imageUrl != null
            ? NetworkImage(user.imageUrl!)
            : null,
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: user.imageUrl == null
            ? Text(
                user.title[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVerified)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.verified,
                size: 16,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
      subtitle: Text(
        '${user.subtitle} • ${_formatFollowers(followers)} followers',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle, color: AppColors.primary),
        onPressed: () => _addTag(user),
      ),
      onTap: () => _addTag(user),
    );
  }

  String _formatFollowers(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// Tagged user model
class TaggedUser {
  const TaggedUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
  };

  factory TaggedUser.fromJson(Map<String, dynamic> json) => TaggedUser(
    id: json['id'] as String,
    username: json['username'] as String,
    displayName: json['displayName'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );
}
