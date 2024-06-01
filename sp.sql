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
	else -- by day
		select date_format(start_time, '%Y-%m-%d') as 'date', count(*) as 'count'
		from collect12
		where (v_start is null or start_time >= v_start)
			and (v_end is null or start_time < v_end)
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
		group by date_format(start_time, '%Y-%m-%d');
	end if;
end;

//
delimiter ;