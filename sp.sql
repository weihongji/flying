delimiter //

-- 各舱各载荷月事件计划项数
drop procedure if exists report01;

create procedure report01(v_year int, group_by char(1), v_task varchar(255), v_load varchar(255))
begin
	if length(v_task) <= 0 then
		set v_task = null;
	end if;
	if length(v_load) <= 0 then
		set v_load = null;
	end if;

	if group_by = 'm' then
		select date_format(create_time, '%Y-%m') as 'date', count(*) as 'count'
		from collect12
		where year(create_time) = v_year
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
		group by date_format(create_time, '%Y-%m');
	else -- by year
		select date_format(create_time, '%Y') as 'date', count(*) as 'count'
		from collect12
		where year(create_time) = v_year
			and (v_task is null or test_task = v_task collate utf8mb4_general_ci)
			and (v_load is null or test_load = v_load collate utf8mb4_general_ci)
		group by date_format(create_time, '%Y');
	end if;
end;

//
delimiter ;