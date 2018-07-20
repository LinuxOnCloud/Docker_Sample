CREATE TABLE THEATER ("ID" INTEGER not null primary key, "CAPACITY" INTEGER not null)
CREATE TABLE MOVIE("ID" INTEGER not null primary key, "NAME" VARCHAR(50) not null, "ACTORS" VARCHAR(200) not null,"POSTER" VARCHAR(200),"RATING" VARCHAR(4), "LINK" VARCHAR(200))
CREATE TABLE TIMESLOT("ID" INTEGER not null primary key, "START_TIME" VARCHAR(5) not null, "END_TIME" VARCHAR(5) not null)
CREATE TABLE SHOW_TIMING("ID" INTEGER not null primary key, "DAY" INTEGER not null, "THEATER_ID" INTEGER not null, "MOVIE_ID" INTEGER not null, "TIMING_ID" INTEGER not null)
CREATE TABLE SALES("ID" INTEGER not null primary key, "AMOUNT" FLOAT not null)
CREATE TABLE POINTS("ID" INTEGER not null primary key, "POINTS" INTEGER not null)
ALTER TABLE SHOW_TIMING ADD CONSTRAINT SHOW_THEATER_FK FOREIGN KEY ("THEATER_ID") REFERENCES THEATER ("ID")
ALTER TABLE SHOW_TIMING ADD CONSTRAINT SHOW_MOVIE_FK FOREIGN KEY ("MOVIE_ID") REFERENCES MOVIE ("ID")
ALTER TABLE SHOW_TIMING ADD CONSTRAINT TIMESLOT_FK FOREIGN KEY ("TIMING_ID") REFERENCES TIMESLOT ("ID")
ALTER TABLE SALES ADD CONSTRAINT SHOW_TIMING_ID_FK FOREIGN KEY ("ID") REFERENCES SHOW_TIMING ("ID")