const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    playerWidth: i32,
    playerHeight: i32,
    playerStartY: i32,
    bulletWidth: f32,
    bulletHeight: f32,
    shieldStartX: f32,
    shieldY: f32,
    shieldWidth: f32,
    shieldHeight: f32,
    shieldSpacing: f32,
    invaderStartX: f32,
    invaderStartY: f32,
    invaderHeightX: f32,
    invaderHeightY: f32,
    InvaderSpacingX: f32,
    InvaderSpacingY: f32,
};

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return Player{ .position_x = position_x, .position_y = position_y, .width = width, .height = height, .speed = 5.0 };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }

        if (self.position_x <= 0) {
            self.position_x = 0;
        }

        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }

    pub fn getRect(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
            .speed = self.speed,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }
};

const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{ .position_x = position_x, .position_y = position_y, .width = width, .height = height, .speed = 10.0, .active = false };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.position_y -= self.speed;
            if (self.position_y < 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: *@This()) void {
        if (self.active) {
            rl.drawRectangle(@intFromFloat(self.position_x), @intFromFloat(self.position_y), @intFromFloat(self.width), @intFromFloat(self.height), rl.Color.red);
        }
    }
};

const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 100.0,
            .alive = true,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.green,
            );
        }
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.position_x += dx;
        self.position_y += dy;
    }
};

pub fn main() void {
    const screen_width = 800;
    const screen_height = 600;

    const max_bullets = 10;
    const bullet_width = 4.0;
    const bullet_height = 10.0;

    const invader_rows = 5;
    const invader_cols = 11;
    const invader_width = 40.0;
    const invader_height = 30.0;
    const invader_startX = 100.0;
    const invader_startY = 50.0;
    const invader_spacingX = 60.0;
    const invader_spacingY = 40.0;
    const invader_speed = 1.0;
    const invader_move_delay = 30;
    const invader_drop_distance = 20.0;

    var invader_direction: f32 = 1.0;
    var move_timer: i32 = 0;

    rl.initWindow(screen_width, screen_height, "Zig Invaders");

    defer rl.closeWindow();

    const player_width = 50.0;
    const player_height = 30.0;
    var player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_height)) - 60.0,
        player_width,
        player_height,
    );

    var bullets: [max_bullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bullet_width, bullet_height);
    }

    var invaders: [invader_rows][invader_cols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invader_startX + @as(f32, @floatFromInt(j)) * invader_spacingX;
            const y = invader_startY + @as(f32, @floatFromInt(i)) * invader_spacingY;
            invader.* = Invader.init(x, y, invader_width, invader_height);
        }
    }

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + player_width / 2 - bullet_width / 2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        move_timer += 1;
        if (move_timer >= invader_move_delay) {
            move_timer = 0;
            var hit_edge = false;

            for (&invaders) |*rows| {
                for (rows) |*invader| {
                    if (invader.alive) {
                        const next_x = invader.position_x + (invader_speed) * invader_direction;
                        if (next_x < 0 or next_x + invader_width > @as(f32, @floatFromInt(screen_width))) {
                            hit_edge = true;
                            break;
                        }
                    }
                }
                if (hit_edge) break;
            }

            if (hit_edge) {
                invader_direction *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invader_speed * invader_direction * 20, invader_drop_distance);
                    }
                }
            } else {
                for (&invaders) |*rows| {
                    for (rows) |*invader| {
                        invader.update(invader_speed * invader_direction * 20, 0);
                    }
                }
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        player.draw();

        for (&bullets) |*bullet| {
            bullet.draw();
        }

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }

        rl.drawText("Zig Invaders", 300, 250, 40, rl.Color.green);
    }

    return;
}
