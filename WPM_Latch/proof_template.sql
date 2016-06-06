DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchCommentsInsertWP
BEFORE INSERT ON wordpress.wp_comments
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;

	 SET result = sys_exec('ruby %PATH%/comment.rb ');
     
	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchCommentsUpdateWP
BEFORE UPDATE ON wordpress.wp_comments
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;

	 SET result = sys_exec('ruby %PATH%/comment.rb ');
     
	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchCommentsDeleteWP
BEFORE DELETE ON wordpress.wp_comments
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;

	 SET result = sys_exec('ruby %PATH%/comment.rb ');
     
	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchPostsInsertWP
BEFORE INSERT ON wordpress.wp_posts
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;
	 DECLARE readonly int;

	 SET readonly = sys_exec('ruby %PATH%/comment.rb');

	 IF readonly NOT IN (0) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Latch Cerrado';
	 END IF;

	 SET result = sys_exec('ruby %PATH%/post.rb ');
     
	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchPostsUpdateWP
BEFORE UPDATE ON wordpress.wp_posts
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;
         DECLARE readonly int;

         SET readonly = sys_exec('ruby %PATH%/comment.rb');

         IF readonly NOT IN (0) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Latch Cerrado';
         END IF;

	 SET result = sys_exec('ruby %PATH%/post.rb ');
     
	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchPostsDeleteWP
BEFORE DELETE ON wordpress.wp_posts
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;

         DECLARE readonly int;

         SET readonly = sys_exec('ruby %PATH%/comment.rb');

         IF readonly NOT IN (0) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Latch Cerrado';
         END IF;

	 SET result = sys_exec('ruby %PATH%/post.rb ');
     
	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchUsermetaInsertWP
BEFORE INSERT ON wordpress.wp_usermeta
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;
	 DECLARE readonly int;

	 SET readonly = sys_exec('ruby %PATH%/comment.rb');
     
	 IF readonly NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        	SET MESSAGE_TEXT = 'Latch Cerrado'; 
	END IF;


	IF NEW.meta_key <> 'session_tokens' THEN	
	        SET result = sys_exec('ruby %PATH%/users.rb ');
		IF result NOT IN (0) THEN
			SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        		SET MESSAGE_TEXT = 'Latch Cerrado';
		END IF;		
        END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchUsermetaUpdateWP
BEFORE UPDATE ON wordpress.wp_usermeta
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE readonly int;
	 DECLARE result int;

	 SET readonly = sys_exec('ruby %PATH%/comment.rb');
     
	 IF readonly NOT IN (0) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Latch Cerrado';
	END IF;

        IF NEW.meta_key <> 'session_tokens' THEN
		SET result = sys_exec('ruby %PATH%/users.rb ');
                IF result NOT IN (0) THEN
                        SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
                        SET MESSAGE_TEXT = 'Latch Cerrado';
                END IF;
        END IF;

END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchUsermetaDeleteWP
BEFORE DELETE ON wordpress.wp_usermeta
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
         DECLARE result int;
         DECLARE readonly int;

         SET readonly = sys_exec('ruby %PATH%/comment.rb');

         IF readonly NOT IN (0) THEN
                SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
                SET MESSAGE_TEXT = 'Latch Cerrado';
        END IF;

         SET result = sys_exec('ruby %PATH%/users.rb ');

        IF result NOT IN (0) THEN
                SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
                SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchUsersInsertWP
BEFORE INSERT ON wordpress.wp_users
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;
	 DECLARE readonly int;

	 SET readonly = sys_exec('ruby %PATH%/comment.rb');
	 SET result = sys_exec('ruby %PATH%/users.rb ');
     
	 IF readonly NOT IN (0) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Latch Cerrado';
	 END IF;

	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchUsersUpdateWP
BEFORE UPDATE ON wordpress.wp_users
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;
	 DECLARE readonly int;

	 SET result = sys_exec('ruby %PATH%/users.rb ');
	 SET readonly = sys_exec('ruby %PATH%/comment.rb ');     

	 IF readonly NOT IN (0) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Latch Cerrado';
         END IF;	 

	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`127.0.0.1`*/ /*!50003 TRIGGER LatchUsersDeleteWP
BEFORE DELETE ON wordpress.wp_users
FOR EACH ROW
BEGIN
	 #DECLARE cmd CHAR(255);
	 DECLARE result int;
	 DECLARE readonly int;

         SET readonly = sys_exec('ruby %PATH%/comment.rb ');

         IF readonly NOT IN (0) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Latch Cerrado';
         END IF;

	 SET result = sys_exec('ruby %PATH%/users.rb ');
     
	 IF  result NOT IN (0) THEN
		SIGNAL SQLSTATE '45000' -- "unhandled user-defined exception"
        SET MESSAGE_TEXT = 'Latch Cerrado';
     END IF;


END */;;
DELIMITER ;

