---
name: social-intelligence
description: |
  Search and monitor social media using X/Twitter (via twit.sh) and Reddit APIs.

  USE FOR:
  - Looking up a specific tweet by ID or URL
  - Searching X/Twitter posts by keywords or hashtags
  - Finding X/Twitter users by criteria
  - Getting a user's recent posts, replies, quote tweets
  - Reading tweet replies and retweets
  - Posting and deleting tweets
  - Searching Reddit posts and discussions
  - Getting comments from Reddit threads
  - Social media monitoring and research

  TRIGGERS:
  - "twitter", "X", "tweets", "posts on X"
  - "read this tweet", "x.com/", "tweet by"
  - "post a tweet", "tweet this", "reply on X"
  - "reddit", "subreddit", "reddit discussion"
  - "what are people saying", "social media", "sentiment"
  - "trending", "viral", "popular posts"
  - "user's posts", "timeline", "recent activity"

  Use `agentcash fetch` for twit.sh (X) and Reddit endpoints. X endpoints $0.0025–$0.01/call; Reddit $0.02/call.

  IMPORTANT: Use exact endpoint paths from the Quick Reference table below.
  KEY ENDPOINT: `GET https://twit.sh/tweets/by/id?id=<tweet_id>` ($0.0025) — use this to read any tweet by ID/URL.
---

# Social Intelligence with x402 APIs

Access X/Twitter (via twit.sh) and Reddit through x402-protected endpoints.

## Setup

See [rules/getting-started.md](rules/getting-started.md) for installation and wallet setup.

## Quick Reference

| Task | Endpoint | Price | Description |
|------|----------|-------|-------------|
| **Look up tweet** | `GET https://twit.sh/tweets/by/id?id=<id>` | $0.0025 | Single tweet by ID |
| Bulk look up tweets | `GET https://twit.sh/tweets?ids=<id1>,<id2>` | $0.01 | Multiple tweets by IDs |
| Search X posts | `GET https://twit.sh/tweets/search` | $0.01 | Search tweets (`words`, `phrase`, `from`, etc.) |
| Get user posts | `GET https://twit.sh/tweets/user?username=<handle>` | $0.01 | User timeline |
| Get replies | `GET https://twit.sh/tweets/replies?id=<tweet_id>` | $0.01 | Replies to a tweet |
| Get quote tweets | `GET https://twit.sh/tweets/quote_tweets?id=<tweet_id>` | $0.01 | Quote tweets of a tweet |
| Get retweets | `GET https://twit.sh/tweets/retweeted_by?id=<tweet_id>` | $0.01 | Users who retweeted |
| Look up user | `GET https://twit.sh/users/by/username?username=<handle>` | $0.005 | User profile by handle |
| Look up user by ID | `GET https://twit.sh/users/by/id?id=<id>` | $0.005 | User profile by numeric ID |
| Find X users | `GET https://twit.sh/users/search?query=<keyword>` | $0.01 | Search users by keyword |
| Get followers | `GET https://twit.sh/users/followers?username=<handle>` | $0.01 | User's followers |
| Get following | `GET https://twit.sh/users/following?username=<handle>` | $0.01 | Who user follows |
| Post tweet | `POST https://twit.sh/tweets` | $0.0025 | Create a tweet or reply |
| Delete tweet | `DELETE https://twit.sh/tweets?id=<id>` | $0.0025 | Delete a tweet |
| Get article | `GET https://twit.sh/articles/by/id?id=<tweet_id>` | $0.01 | Full X Article content |
| Search Reddit | `POST https://stableenrich.dev/api/reddit/search` | $0.02 | Search Reddit posts |
| Get comments | `POST https://stableenrich.dev/api/reddit/post-comments` | $0.02 | Comments on a post |

See [rules/rate-limits.md](rules/rate-limits.md) for usage guidance.

## X/Twitter via twit.sh

All twit.sh endpoints are GET with query parameters. Run `agentcash discover https://twit.sh` or `agentcash check https://twit.sh/<path>` for full parameter lists.

### Search Posts

Search for X posts by keywords (at least one filter required):

```bash
agentcash fetch "https://twit.sh/tweets/search?words=AI%20agents"
```

**Parameters (query string):**
- `words` - All these words must appear
- `phrase` - Exact phrase match
- `anyWords` - Any of these words
- `from` - Tweets from this username
- `minLikes`, `minReplies`, `minReposts` - Engagement filters
- `since`, `until` - Date range (YYYY-MM-DD)
- `next_token` - Pagination cursor

**Returns:** Up to 20 tweets per page, X v2 API–compatible JSON (text, author, metrics, timestamps, media).

### Search Users

Find X users matching a keyword:

```bash
agentcash fetch "https://twit.sh/users/search?query=AI%20researcher%20San%20Francisco"
```

**Parameters:**
- `query` - Search keyword or phrase (required)

**Returns:** Up to 20 user profiles per page (username, display name, bio, followers, verification, profile image).

### Get User's Posts

Fetch recent posts from a specific user:

```bash
agentcash fetch "https://twit.sh/tweets/user?username=elonmusk"
```

**Parameters:**
- `username` - X username without @ (required)

**Returns:** Up to 20 tweets per page from the user's timeline.

## Reddit

### Search Posts

Search Reddit for posts:

```bash
agentcash fetch https://stableenrich.dev/api/reddit/search -m POST -b '{"query": "best programming languages 2024"}'
```

**Parameters:**
- `query` - Search terms (required)
- `subreddit` - Limit to specific subreddit
- `sort` - relevance, hot, new, top
- `time` - hour, day, week, month, year, all

**Returns:**
- Post title and content
- Author and subreddit
- Upvotes and comment count
- Post URL

### Search in Subreddit

```bash
agentcash fetch https://stableenrich.dev/api/reddit/search -m POST -b '{
  "query": "typescript vs javascript",
  "subreddit": "programming",
  "sort": "top",
  "time": "year"
}'
```

### Get Post Comments

Get comments from a Reddit post:

```bash
agentcash fetch https://stableenrich.dev/api/reddit/post-comments -m POST -b '{"postUrl": "https://reddit.com/r/programming/comments/abc123/..."}'
```

**Returns:**
- Comment text and author
- Upvotes/downvotes
- Reply threads
- Comment timestamps

## Workflows

### Standard

- [ ] (Optional) Check balance: `agentcash wallet info`
- [ ] Use `agentcash discover https://twit.sh` or `https://stableenrich.dev` to list endpoints
- [ ] Use `agentcash check <endpoint-url>` to see expected parameters and pricing
- [ ] Call endpoint with `agentcash fetch`
- [ ] Parse and present results

### Brand Monitoring

- [ ] (Optional) Check balance: `agentcash wallet info`
- [ ] Search X for brand mentions
- [ ] Search Reddit for discussions
- [ ] Summarize sentiment and key mentions

```bash
agentcash fetch "https://twit.sh/tweets/search?words=YourBrand&from=YourBrand"
```

```bash
agentcash fetch https://stableenrich.dev/api/reddit/search -m POST -b '{"query": "YourBrand", "sort": "new"}'
```

### Competitor Research

- [ ] Search Reddit for competitor reviews
- [ ] Search X for competitor mentions
- [ ] Analyze common complaints and praise

```bash
agentcash fetch https://stableenrich.dev/api/reddit/search -m POST -b '{"query": "competitor name review", "sort": "top", "time": "year"}'
```

### Influencer Discovery

- [ ] Define criteria (topic, follower range)
- [ ] Search for matching users
- [ ] Get recent posts for top candidates

```bash
agentcash fetch "https://twit.sh/users/search?query=tech%20blogger%20100k%20followers"
```

### Community Sentiment

- [ ] Identify relevant subreddit
- [ ] Search for discussions on topic
- [ ] Get comments from top posts
- [ ] Synthesize overall sentiment

```bash
agentcash fetch https://stableenrich.dev/api/reddit/search -m POST -b '{"query": "new feature name", "subreddit": "relevant_community", "sort": "hot"}'
```

```bash
agentcash fetch https://stableenrich.dev/api/reddit/post-comments -m POST -b '{"postUrl": "https://reddit.com/..."}'
```

## Response Data

### X/Twitter Post Fields
- `text` - Post content
- `author` - Username, display name, verified status
- `metrics` - Likes, retweets, replies, quotes, views
- `createdAt` - Timestamp
- `url` - Link to post
- `media` - Attached images/videos

### X/Twitter User Fields
- `username` - Handle without @
- `displayName` - Full name
- `description` - Bio
- `followers` / `following` - Counts
- `verified` - Verification status
- `profileImageUrl` - Avatar

### Reddit Post Fields
- `title` - Post title
- `selftext` - Post body (for text posts)
- `author` - Username
- `subreddit` - Subreddit name
- `score` - Upvotes minus downvotes
- `numComments` - Comment count
- `url` - Link to post
- `createdUtc` - Timestamp

### Reddit Comment Fields
- `body` - Comment text
- `author` - Username
- `score` - Net upvotes
- `replies` - Nested replies
- `createdUtc` - Timestamp

## Cost Estimation

| Task | Calls | Cost |
|------|-------|------|
| Quick X search | 1 | $0.01 |
| User profile + posts | 2 | $0.015–0.02 |
| Reddit thread + comments | 2 | $0.04 |
| Full monitoring scan | 4-6 | $0.08-0.12 |
