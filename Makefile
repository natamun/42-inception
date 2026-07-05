NAME		= inception
COMPOSE		= srcs/docker-compose.yml
DATA_PATH	= $(HOME)/data

all:
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	@docker compose -f $(COMPOSE) up --build -d

clean:
	@docker compose -f $(COMPOSE) down -v

fclean: clean
	@docker system prune -af
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all clean fclean re
