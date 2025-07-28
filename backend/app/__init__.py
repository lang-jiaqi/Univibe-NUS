from flask import Flask
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Register login blueprint
    from .routes.login import login_bp
    app.register_blueprint(login_bp)

    # Register register blueprint
    from .routes.register import register_bp
    app.register_blueprint(register_bp)

    # Register log blueprint
    from .routes.log import log_bp
    app.register_blueprint(log_bp)

    # Register garden blueprint
    from .routes.garden import garden_bp
    app.register_blueprint(garden_bp)

    # Register virtual character blueprint
    from .routes.character import character_bp
    app.register_blueprint(character_bp)

    # Register connections blueprint
    from .routes.connections import connection_bp
    app.register_blueprint(connection_bp)

    # Register setting blueprint
    from .routes.setting import setting_bp
    app.register_blueprint(setting_bp)

    # Register fithub blueprint
    from .routes.fithub import fithub_bp
    app.register_blueprint(fithub_bp)

    # Register route explorer blueprint
    from .routes.route_explorer import route_explorer_bp
    app.register_blueprint(route_explorer_bp)

    # Register my post blueprint
    from .routes.my_post import my_post_bp
    app.register_blueprint(my_post_bp)

    return app