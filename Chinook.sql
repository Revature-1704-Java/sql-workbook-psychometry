/*2.0 SQL Queries*/
select * from employee;
select * from employee where LASTNAME='King';
select * from employee where FIRSTNAME='Andrew' and REPORTSTO is null;
select * from album order by title;
select FIRSTNAME, LASTNAME from customer order by city desc;
insert into genre values(26,'Electric Funk');
insert into genre values(27,'Glitch-hop');
insert into employee (FIRSTNAME,LASTNAME,EMPLOYEEID)values('Ace', 'Ventura',9);
insert into employee (FIRSTNAME,LASTNAME,EMPLOYEEID)values('Jonas', 'Venture',10);
insert into customer (customerid, firstname,lastname, email) values(60, 'Rusty', 'Venture','123@234');
insert into customer (customerid, firstname,lastname, email) values(61, 'Rusty', 'Venture','123@234');
update customer set firstname='Robert', lastname='Walter' where firstname = 'Aaron' and lastname = 'Mitchell';
update artist set name='CCR' where name= 'Creedence Clearwater Revival';
select * from invoice where billingaddress like 'T%';
select * from invoice where total between 15 and 50;
select * from EMPLOYEE where HIREDATE between '01-JUN-2003' and '01-MAR-2004';
Alter table invoice drop constraint FK_InvoiceCustomerid;
ALTER TABLE Invoice ADD CONSTRAINT FK_InvoiceCustomerId
    FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId) on delete cascade;
alter table InvoiceLine drop constraint FK_InvoiceLineInvoiceId;
ALTER TABLE InvoiceLine ADD CONSTRAINT FK_InvoiceLineInvoiceId
    FOREIGN KEY (InvoiceId) REFERENCES Invoice (InvoiceId) on delete cascade;
delete from customer where firstname='Robert' and lastname='Walter';
/*3.0 SQL Functions*/
create or replace function get_current_time return timestamp is 
begin
    return LOCALTIMESTAMP;
end;
/

create or replace function get_length(iname in varchar2) return number 
is mlength Number;
begin 
    select length(name) into mlength from mediatype where name=iname;
    return mlength;
end;
/

create or replace function get_average_price return number is x Number;
begin
    select avg(total) into x from invoice;
    return x;
end;
/
select get_average_price() from dual;

create or replace function get_most_expensive_track return varchar2 is x number; n varchar2(100);
begin
    select max(UNITPRICE) into x from track;
    select name into n from track where UNITPRICE = x and rownum=1;
    return n;
end;
/
select GET_MOST_EXPENSIVE_TRACK() from dual;

create or replace function get_average_total return number is 
x Number;
sum1 Number;
sum2 Number;
begin
    sum1:=0;
    sum2:=0;
    for i in (select unitprice*quantity u, quantity from invoiceline)
    loop
        sum1:=sum1+i.u;
        sum2:=sum2+i.quantity;
    end loop;
    x:=sum1/sum2;
    return x;
end;
/
select get_average_total() from dual;

create or replace type EmployeeType as object(
    employeeid integer,
    lastname varchar2(20),
    firstname varchar2(20)
);
/
create or replace type TableForEmployee as table of EmployeeType;
/

create or replace function get_young return TableForEmployee is tlist TableForEmployee;
begin
    select EmployeeType(employeeid, firstname, lastname) bulk collect into tlist from employee where birthdate> to_date('1968','yyyy');
    return tlist;
end;
/
select*from table(get_young());

/*4.0 Stored Procedure*/
create or replace procedure select_all_employee(s out SYS_REFCURSOR) is 
begin
    open s for 
    select firstname,lastname from employee;
end;
/
declare
    s sys_refcursor;
    n employee.lastname%TYPE;
    f employee.firstname%TYPE;
begin
    select_all_employee(s);
    DBMS_OUTPUT.put_line('fuck you');
    loop 
        fetch s into f, n;
        exit when s%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(n||' '||f);
    end loop;
    CLOSE s;
end;
/

create or replace procedure update_employee (e_id in number, new_num in varchar2) as
begin
    update employee set phone= new_num where employeeid=e_id;
end;
/
begin
    update_employee(10, '1234567890');
    commit;
end;
/

create or replace procedure find_manager (e_id in number, m out number) as
begin
    select REPORTSTO into m from employee where employeeid=e_id; 
end;
/
declare
    m_id number;
begin
    find_manager(2,m_id);
    dbms_output.put_line(m_id);
end;
/

create or replace procedure find_company_name(c_id in number, c_name out varchar2, cp out varchar2 ) is
begin
    select firstname||' '||lastname into c_name from customer where customerid=c_id; 
    select company into cp from customer where customerid=c_id; 
end;
/
declare
    c_name varchar2(200);
    company varchar2(100);
begin
    find_company_name(1, c_name, company);
    dbms_output.put_line(c_name||' '||company);
end;
/
/*5.0 Transaction*/
begin
    delete from invoiceline where invoiceid=21; 
    delete from invoice where invoiceid=21;
    commit;
end;
/

create or replace procedure insert_new_customer (c_id number, c_first varchar2, c_last varchar2, c_em varchar2) is
begin
    insert into customer(customerid, firstname, lastname, email) values(c_id, c_first, c_last, c_em);
    commit;
end;
/

/*6.0 Triggers*/

create or replace trigger after_employee_insert
after insert on
employee
begin
DBMS_output.put_line('employee');
end;
/
create or replace trigger after__update
after update on 
album
begin
DBMS_output.put_line('album update');
end;
/
create or replace trigger after_delete
after delete on 
customer
for each row
begin
DBMS_output.put_line('delete');
end;
/

/*7.0 Joins*/

select firstname, lastname, invoiceid from customer
inner join invoice on customer.customerid = invoice.customerid;

select customer.customerid, firstname, lastname, invoiceid, total 
from customer left outer join invoice 
on customer.customerid = invoice.customerid;

select name, title from album right outer join artist on album.artistid=artist.artistid; 

select * from album cross join artist order by artist.name asc;

select em.* from employee em join employee man on em.REPORTSTO=man.employeeid;

select * from invoice join customer on invoice.customerid = customer.customerid
join invoiceline on invoice.invoiceid = invoiceline.invoiceid
join employee on customer.supportrepid = employee.employeeid
join track on invoiceline.TRACKID = track.trackid
join playlisttrack on track.TRACKID = playlisttrack.TRACKID
join PLAYLIST on playlisttrack.PLAYLISTID = PLAYLIST.PLAYLISTID
join genre on track.GENREID = genre.GENREID
join MEDIATYPE on track.MEDIATYPEID = MEDIATYPE.MEDIATYPEID
join ALBUM on track.ALBUMID = ALBUM.ALBUMID
join artist on artist.ARTISTID = ALBUM.ARTISTID;