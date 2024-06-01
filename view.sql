delimiter //

create or replace view collect10 as
select c1.form_no as 'report_no'
	, c1.data_value as 'form_number' -- 表单编号
    , c1.create_time
	, c2.data_value as 'task' -- 任务代号
	, c3.data_value as 'load' -- 载荷名称
	, c4.data_value as 'test' -- 实验名称
	, c5.data_value as 'purpose' -- 实验目的
	, c6.data_value as 'importance' -- 重要程度
	, c7.data_value as 'maturity' -- 成熟程度
	, c8.data_value as 'type' -- 实验方式
	, s1.data_value as 'moon_event_id' -- 月事件id
	, substring(s2.data_value, 2, 19) as 'start' -- 开始时间
	, substring(s2.data_value, 23, 19) as 'end' -- 结束时间
	, round(timestampdiff(minute, substring(s2.data_value, 2, 19), substring(s2.data_value, 23, 19))/60, 2) as 'elapse' -- 实验时长
	, s3.data_value as 'power' -- 实验功耗
	, s4.data_value as 'resource' -- 上行资源需求
	, s5.data_value as 'frame' -- 上行资源需求帧数
	, s6.data_value as 'transmission' -- 数据输出速率
	, s7.data_value as 'flight' -- 飞行姿态需求
	, s8.data_value as 'person_hour' -- 航天员需求
	, s9.data_value as 'camera' -- 相机需求
	, s10.data_value as 'communication' -- 天地通话需求
	, s11.data_value as 'arm' -- 机械臂需求
	, s12.data_value as 'supplies' -- 物资需求
	, s13.data_value as 'more_supplies' -- 其它需求
from flying_form_collect c1
	left join flying_form_collect c2 on c2.instance_id = c1.instance_id and c2.data_key = '任务代号'
	left join flying_form_collect c3 on c3.instance_id = c1.instance_id and c3.data_key = '载荷名称'
	left join flying_form_collect c4 on c4.instance_id = c1.instance_id and c4.data_key = '实验名称'
	left join flying_form_collect c5 on c5.instance_id = c1.instance_id and c5.data_key = '实验目的'
	left join flying_form_collect c6 on c6.instance_id = c1.instance_id and c6.data_key = '重要程度'
	left join flying_form_collect c7 on c7.instance_id = c1.instance_id and c7.data_key = '成熟程度'
	left join flying_form_collect c8 on c8.instance_id = c1.instance_id and c8.data_key = '实验方式'
	left join flying_form_collect s1 on s1.instance_id = c1.instance_id and s1.data_key = '月事件id'
	left join flying_form_collect s2 on s2.instance_id = c1.instance_id and s2.group_id = s1.group_id and s2.data_key = '开始时间-结束时间'
	left join flying_form_collect s3 on s3.instance_id = c1.instance_id and s3.group_id = s1.group_id and s3.data_key = '实验功耗'
	left join flying_form_collect s4 on s4.instance_id = c1.instance_id and s4.group_id = s1.group_id and s4.data_key = '上行资源需求'
	left join flying_form_collect s5 on s5.instance_id = c1.instance_id and s5.group_id = s1.group_id and s5.data_key = '上行资源需求帧数'
	left join flying_form_collect s6 on s6.instance_id = c1.instance_id and s6.group_id = s1.group_id and s6.data_key = '数据输出速率'
	left join flying_form_collect s7 on s7.instance_id = c1.instance_id and s7.group_id = s1.group_id and s7.data_key = '飞行姿态需求'
	left join flying_form_collect s8 on s8.instance_id = c1.instance_id and s8.group_id = s1.group_id and s8.data_key = '航天员需求'
	left join flying_form_collect s9 on s9.instance_id = c1.instance_id and s9.group_id = s1.group_id and s9.data_key = '相机需求'
	left join flying_form_collect s10 on s10.instance_id = c1.instance_id and s10.group_id = s1.group_id and s10.data_key = '天地通话需求'
	left join flying_form_collect s11 on s11.instance_id = c1.instance_id and s11.group_id = s1.group_id and s11.data_key = '机械臂需求'
	left join flying_form_collect s12 on s12.instance_id = c1.instance_id and s12.group_id = s1.group_id and s12.data_key = '物资需求'
	left join flying_form_collect s13 on s13.instance_id = c1.instance_id and s13.group_id = s1.group_id and s13.data_key = '其它需求'
where c1.form_no = 10
	and c1.data_key = '表单编号';


create or replace view collect12 as
select c1.form_no as 'report_no'
	, c1.data_value as 'form_number' -- 表单编号
    , c1.create_time
	, c2.data_value as 'task' -- 任务代号
	, c3.data_value as 'load' -- 载荷名称
	, s1.data_value as 'test_task' -- 实验任务代号
	, s2.data_value as 'test_load' -- 实验载荷名称
	, s3.data_value as 'test_name' -- 实验名称
	, s4.data_value as 'start_end' -- 开始时间-结束时间
	, s5.data_value as 'person_hour' -- 航天员人时
	, s6.data_value as 'fly_event_id' -- 飞控事件id
	, s7.data_value as 'moon_event_id' -- 月事件id
from flying_form_collect c1
	left join flying_form_collect c2 on c2.instance_id = c1.instance_id and c2.data_key = '任务代号'
	left join flying_form_collect c3 on c3.instance_id = c1.instance_id and c3.data_key = '载荷名称'
	left join flying_form_collect s1 on s1.instance_id = c1.instance_id and s1.data_key = '实验任务代号'
	left join flying_form_collect s2 on s2.instance_id = c1.instance_id and s2.group_id = s1.group_id and s2.data_key = '实验载荷名称'
	left join flying_form_collect s3 on s3.instance_id = c1.instance_id and s3.group_id = s1.group_id and s3.data_key = '实验名称'
	left join flying_form_collect s4 on s4.instance_id = c1.instance_id and s4.group_id = s1.group_id and s4.data_key = '开始时间-结束时间'
	left join flying_form_collect s5 on s5.instance_id = c1.instance_id and s5.group_id = s1.group_id and s5.data_key = '航天员人时'
	left join flying_form_collect s6 on s6.instance_id = c1.instance_id and s6.group_id = s1.group_id and s6.data_key = '飞控事件id'
	left join flying_form_collect s7 on s7.instance_id = c1.instance_id and s7.group_id = s1.group_id and s7.data_key = '月事件id'
where c1.form_no = 12
	and c1.data_key = '表单编号';

//
delimiter ;