# Check-Game Database Schema

## Database: PostgreSQL 15+

### Overview
The database is designed to support user management, session handling, game state persistence, and tournament tracking for the Check-Game multiplayer card game.

## Schema Design

### Users Table
Stores registered user accounts.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### Refresh Tokens Table
Manages JWT refresh tokens for authentication.

```sql
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
```

### Sessions Table
Manages game sessions where players compete in tournaments.

```sql
CREATE TYPE session_status AS ENUM ('waiting', 'active', 'completed');

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50),
    join_code VARCHAR(6) UNIQUE NOT NULL,
    max_players INTEGER NOT NULL CHECK (max_players >= 2 AND max_players <= 8),
    current_players INTEGER DEFAULT 0,
    is_private BOOLEAN DEFAULT false,
    status session_status DEFAULT 'waiting',
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    winner_id UUID REFERENCES users(id)
);

CREATE INDEX idx_sessions_join_code ON sessions(join_code);
CREATE INDEX idx_sessions_status ON sessions(status);
CREATE INDEX idx_sessions_created_by ON sessions(created_by);
CREATE INDEX idx_sessions_created_at ON sessions(created_at);
```

### Session Players Table
Tracks players in each session (both registered and anonymous).

```sql
CREATE TABLE session_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    anonymous_name VARCHAR(20),
    is_anonymous BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    is_eliminated BOOLEAN DEFAULT false,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    left_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT chk_user_or_anonymous CHECK (
        (user_id IS NOT NULL AND anonymous_name IS NULL AND is_anonymous = false) OR
        (user_id IS NULL AND anonymous_name IS NOT NULL AND is_anonymous = true)
    )
);

CREATE UNIQUE INDEX idx_session_players_session_user ON session_players(session_id, user_id) 
    WHERE user_id IS NOT NULL;
CREATE INDEX idx_session_players_session_id ON session_players(session_id);
CREATE INDEX idx_session_players_user_id ON session_players(user_id);
```

### Games Table
Individual games within a session.

```sql
CREATE TYPE game_status AS ENUM ('waiting', 'active', 'completed');

CREATE TABLE games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    game_number INTEGER NOT NULL,
    status game_status DEFAULT 'waiting',
    current_player_id UUID REFERENCES session_players(id),
    winner_id UUID REFERENCES session_players(id),
    loser_id UUID REFERENCES session_players(id),
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(session_id, game_number)
);

CREATE INDEX idx_games_session_id ON games(session_id);
CREATE INDEX idx_games_status ON games(status);
CREATE INDEX idx_games_started_at ON games(started_at);
```

### Game Players Table
Players participating in a specific game.

```sql
CREATE TABLE game_players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    session_player_id UUID NOT NULL REFERENCES session_players(id) ON DELETE CASCADE,
    hand_size INTEGER DEFAULT 7,
    play_order INTEGER NOT NULL,
    is_eliminated BOOLEAN DEFAULT false,
    eliminated_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(game_id, session_player_id),
    UNIQUE(game_id, play_order)
);

CREATE INDEX idx_game_players_game_id ON game_players(game_id);
CREATE INDEX idx_game_players_session_player_id ON game_players(session_player_id);
```

### Game State Table
Stores the current state of active games.

```sql
CREATE TYPE card_suit AS ENUM ('spades', 'hearts', 'diamonds', 'clubs');
CREATE TYPE card_rank AS ENUM ('A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'Joker');
CREATE TYPE card_color AS ENUM ('red', 'black');

CREATE TABLE game_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    current_card_suit card_suit,
    current_card_rank card_rank,
    current_card_color card_color,
    draw_pile_size INTEGER NOT NULL DEFAULT 52,
    discard_pile_size INTEGER NOT NULL DEFAULT 1,
    attack_stack INTEGER DEFAULT 0,
    chosen_suit card_suit, -- For Jack card suit selection
    turn_direction INTEGER DEFAULT 1, -- 1 for clockwise, -1 for counter-clockwise
    skip_next_player BOOLEAN DEFAULT false,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(game_id)
);

CREATE INDEX idx_game_states_game_id ON game_states(game_id);
```

### Game Actions Table
Log of all actions taken during games (for replay and audit).

```sql
CREATE TYPE action_type AS ENUM (
    'play_card', 'draw_card', 'skip_turn', 'choose_suit', 
    'attack', 'defend', 'eliminate', 'win', 'start_game'
);

CREATE TABLE game_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    game_player_id UUID NOT NULL REFERENCES game_players(id) ON DELETE CASCADE,
    action_type action_type NOT NULL,
    card_suit card_suit,
    card_rank card_rank,
    chosen_suit card_suit,
    target_player_id UUID REFERENCES game_players(id),
    cards_drawn INTEGER,
    metadata JSONB, -- Additional action-specific data
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_game_actions_game_id ON game_actions(game_id);
CREATE INDEX idx_game_actions_game_player_id ON game_actions(game_player_id);
CREATE INDEX idx_game_actions_created_at ON game_actions(created_at);
```

### Player Statistics Table
Aggregated statistics for registered users.

```sql
CREATE TABLE player_statistics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_games INTEGER DEFAULT 0,
    games_won INTEGER DEFAULT 0,
    games_lost INTEGER DEFAULT 0,
    sessions_created INTEGER DEFAULT 0,
    sessions_joined INTEGER DEFAULT 0,
    tournaments_won INTEGER DEFAULT 0,
    cards_played INTEGER DEFAULT 0,
    average_game_duration INTERVAL,
    last_played_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id)
);

CREATE INDEX idx_player_statistics_user_id ON player_statistics(user_id);
```

## Indexes and Constraints

### Additional Indexes
```sql
-- Composite indexes for common queries
CREATE INDEX idx_sessions_status_created_at ON sessions(status, created_at);
CREATE INDEX idx_games_session_status ON games(session_id, status);
CREATE INDEX idx_game_players_game_eliminated ON game_players(game_id, is_eliminated);

-- Partial indexes for active records
CREATE INDEX idx_active_sessions ON sessions(created_at) WHERE status IN ('waiting', 'active');
CREATE INDEX idx_active_games ON games(started_at) WHERE status = 'active';
```

### Database Functions
```sql
-- Function to automatically update current_players count
CREATE OR REPLACE FUNCTION update_session_player_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE sessions 
        SET current_players = current_players + 1
        WHERE id = NEW.session_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE sessions 
        SET current_players = current_players - 1
        WHERE id = OLD.session_id;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' AND OLD.is_active != NEW.is_active THEN
        IF NEW.is_active THEN
            UPDATE sessions 
            SET current_players = current_players + 1
            WHERE id = NEW.session_id;
        ELSE
            UPDATE sessions 
            SET current_players = current_players - 1
            WHERE id = NEW.session_id;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to maintain player count
CREATE TRIGGER trigger_update_session_player_count
    AFTER INSERT OR UPDATE OR DELETE ON session_players
    FOR EACH ROW EXECUTE FUNCTION update_session_player_count();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_player_statistics_updated_at
    BEFORE UPDATE ON player_statistics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Data Relationships

### Primary Relationships
- Users can create multiple Sessions
- Sessions contain multiple Games (tournament style)
- Games have multiple Game Players
- Game Players are linked to Session Players
- Game Actions track all moves in games

### Key Business Rules
1. Only registered users can create sessions
2. Both registered and anonymous users can join sessions
3. Sessions have a maximum player limit (2-8)
4. Games within a session eliminate players progressively
5. Tournament continues until one player remains
6. All game actions are logged for replay/audit
7. Statistics are maintained for registered users only

## Performance Considerations

### Query Optimization
- Proper indexing on frequently queried columns
- Composite indexes for multi-column queries
- Partial indexes for filtered queries
- Foreign key indexes for join performance

### Data Archival
- Consider archiving completed sessions after a certain period
- Game actions can be archived separately for long-term storage
- Refresh tokens should be cleaned up regularly

### Connection Pooling
- Use Prisma's built-in connection pooling
- Configure appropriate pool size based on expected concurrent users
- Monitor connection usage and adjust as needed

## Backup Strategy

### Regular Backups
- Daily full database backups
- Hourly incremental backups during peak hours
- Point-in-time recovery capability
- Cross-region backup replication for disaster recovery

### Critical Data Priority
1. User accounts and authentication data
2. Active session and game states
3. Game action logs (for dispute resolution)
4. Player statistics and historical data