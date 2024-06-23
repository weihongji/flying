delimiter //

-- 各舱各载荷月事件计划项数
drop procedure if exists report01;

create procedure report01(v_start date, v_end date, group_by char(1), v_task varchar(255), v_load varchar(255))
begin
	if length(v_task) <= 0 then
		set v_task = null;
	end if;
	if length(v_load) <= 0 then
		set v_load = null;
	end if;
	if v_end is not null then
		set v_end = date_add(v_end, interval 1 day);
	end if;

	if group_by = 'm' then -- month
		select date_format(start_time, '%Y-%m') as 'date', count(*) as 'count'
		from collect12
		where (v_start is null or start_time >= v_start)
			and (v_end is null or start_time < v_end)
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
		group by date_format(start_time, '%Y-%m');
	elseif group_by = 'y' then -- year
		select date_format(start_time, '%Y') as 'date', count(*) as 'count'
		from collect12
		where (v_start is null or start_time >= v_start)
			and (v_end is null or start_time < v_end)
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
		group by date_format(start_time, '%Y');
	elseif group_by = 'd' then -- day
		select date_format(start_time, '%Y-%m-%d') as 'date', count(*) as 'count'
		from collect12
		where (v_start is null or start_time >= v_start)
			and (v_end is null or start_time < v_end)
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
		group by date_format(start_time, '%Y-%m-%d');
	elseif group_by = 'w' then -- week
		select year(start_time) as 'year', weekofyear(start_time) as 'week'
			, date_format(date_add(min(start_time), interval -weekday(min(start_time)) day), '%Y-%m-%d') as 'date' -- Monday of the week
			, count(*) as 'count'
		from collect12
		where (v_start is null or start_time >= v_start)
			and (v_end is null or start_time < v_end)
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
		group by year(start_time), weekofyear(start_time)
		order by 1, 2;
	elseif group_by = 'e' then -- 月事件id. 在一个月中，各月事件id出现的次数，若某事件id在一周内出现多次，则本周只计一次。
		select `year`, `month`, moon_event_id, count(*) as 'count'
		from (
				select year(start_time) as 'year', month(start_time) as 'month', moon_event_id, weekofyear(start_time) as 'week'
				from collect12
				where (v_start is null or start_time >= v_start)
					and (v_end is null or start_time < v_end)
					and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
					and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
					and moon_event_id <> ''
				group by year(start_time), month(start_time), moon_event_id, weekofyear(start_time)
			) x
		group by `year`, `month`, moon_event_id
		order by 1, 2, 3;
	else -- total of all
		select date_format(min(start_time), '%Y-%m-%d') as 'date', count(*) as 'count'
		from collect12
		where (v_start is null or start_time >= v_start)
			and (v_end is null or start_time < v_end)
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci);
	end if;
end;

-- 为性能测试生成数据, 数据放在表collect_mock
drop procedure if exists mock;

create procedure mock(copies int)
begin
	declare start_date date default '2024-01-01';
	declare end_date date default current_date(); -- Not included
	declare days int default datediff(end_date, start_date);
	declare count_per_day int default 1;
	declare v_date date;
	declare i int default 1; -- counter from 1 to number of copies
	declare day_i int;
	declare max_id bigint;
	
	if copies > days then
		set count_per_day = copies / days;
	end if;
	
	create temporary table if not exists instance (
		instance_id varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
		new_id varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci
	);
	insert into instance (instance_id, new_id)
	select distinct instance_id, '' from flying_form_collect;

	truncate table collect_mock;

	set v_date = start_date;
	while v_date < end_date and i <= copies do
		set day_i = 1;
		while day_i <= count_per_day and i <= copies do
			update instance set new_id = uuid();
			select ifnull(max(id), 10000000000) into max_id from collect_mock;
			
			insert into collect_mock (id, instance_id, create_time, group_id, form_no, data_key, data_value, is_summary_data, row_no, status, create_by)
			select max_id + row_number() over (order by id) as id
				, s.new_id as instance_id
				, timestamp(v_date, sec_to_time(floor(day_i/count_per_day * (4 * 3600)))) as create_time
				, group_id
				, form_no
				, data_key
				, case when data_key in ('开始时间', '发生时间', '飞控事件开始时间') then
						timestamp(v_date, maketime(6 + floor(rand() * 6), 0, 0)) -- 6:00 ~ 12:00
					when data_key in ('飞控事件结束时间') then
						timestamp(v_date, maketime(12 + floor(rand() * 6), 0, 0)) -- 12:00 ~ 18:00
					when data_key = '表单编号' then
						regexp_replace(data_value, '-[0-9]{8,8}-[0-9]+', concat('-', date_format(v_date, '%Y%m%d'), '-', day_i))
					when data_key in ('开始时间-结束时间', '操作开始时间-操作结束时间') then -- [2024-06-26 00:00:00, 2024-06-27 00:00:00]
						concat('['
							, date_format(timestamp(v_date, maketime(6 + floor(rand() * 6), 0, 0)), '%Y-%m-%d %H:%i:%s')
							, ', '
							, date_format(timestamp(v_date, maketime(12 + floor(rand() * 6), 0, 0)), '%Y-%m-%d %H:%i:%s')
							, ']')
					else data_value
				end as data_value
				, is_summary_data, row_no, status, create_by
			from flying_form_collect c inner join instance s on s.instance_id = c.instance_id;
			
			set day_i = day_i + 1;
			set i = i + 1;
		end while;
		set v_date = date_add(v_date, interval 1 day);
	end while;
	
	select count(*) as 'count' from collect_mock;
	drop temporary table instance;
end;
//
delimiter ;