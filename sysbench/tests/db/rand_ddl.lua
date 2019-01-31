pathtest = string.match(test, "(.*/)")

if pathtest then
   dofile(pathtest .. "common.lua")
else
   require("common")
end

function thread_init(thread_id)
   set_vars()

   if (((db_driver == "mysql") or (db_driver == "attachsql")) and mysql_table_engine == "myisam") then
      local i
      local tables = {}
      for i=1, oltp_tables_count do
         tables[i] = string.format("sbtest%i WRITE", i)
      end
      begin_query = "LOCK TABLES " .. table.concat(tables, " ,")
      commit_query = "UNLOCK TABLES"
   else
      begin_query = "BEGIN"
      commit_query = "COMMIT"
   end

end

function event(thread_id)
   local rs
   local i
   local table_name
   local range_start
   local c_val
   local pad_val
   local query
   local n
   local col_type
   local types = {"int ", "int default 1",
                 "bigint", "bigint default 100",
                 "char(100)", "char(100) default \\'charabc\\'",
                 "varchar(100)", "varchar(100) default \\'varchabc\\'",
                 "text", "blob",
                 "double", "double default 111"}


   table_name = "sbtest".. sb_rand_uniform(1, oltp_tables_count)

   n = sb_rand_uniform(0, 20);
   col_name1 = "c".. n
   n = (n + 1) % 20
   col_name2 = "c".. n

   type=sb_rand_uniform(1, 8)

   if type == 1 then
     col_type = types[sb_rand_uniform(1, 12)]
     rs = db_query("call add_col('".. table_name .."','" .. col_name1 .. "','"..col_type.."')")
   elseif type == 2 then
     rs = db_query("call drop_col('".. table_name .."','" .. col_name1 .. "')")
   elseif type == 3 then
     index_name = "idx".. sb_rand_uniform(0, 10)
     rs = db_query("call add_index('test','".. table_name .."','".. index_name .."','" .. col_name1 .. "')")
   elseif type == 4 then
     index_name = "idx".. sb_rand_uniform(0, 10)
     rs = db_query("call add_index2('test','".. table_name .."','".. index_name .."','" .. col_name1 .. "','".. col_name2 .."')")
   elseif type == 5 then
     index_name = "idx".. sb_rand_uniform(0, 10)
     rs = db_query("call drop_index('test','".. table_name .."','" .. index_name .. "')")
   elseif type == 6 then
     rs = db_query("alter table ".. table_name .." engine=innodb")
   elseif type == 798 then
     tmp_name = "tttt".. sb_rand_uniform(0, 10)
     rs = db_query("create table ".. tmp_name .. " like ".. table_name)
     rs = db_query("drop table ".. table_name)
     rs = db_query("rename table ".. tmp_name .. " to " .. table_name)
   end

   if not oltp_skip_trx then
      db_query(begin_query)
   end

   if not oltp_write_only then

   for i=1, oltp_point_selects do
      rs = db_query("SELECT c FROM ".. table_name .." WHERE id=" .. sb_rand(1, oltp_table_size))
   end

   if oltp_range_selects then

   for i=1, oltp_simple_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT c FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1)
   end
  
   for i=1, oltp_sum_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT SUM(K) FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1)
   end
   
   for i=1, oltp_order_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT c FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1 .. " ORDER BY c")
   end

   for i=1, oltp_distinct_ranges do
      range_start = sb_rand(1, oltp_table_size)
      rs = db_query("SELECT DISTINCT c FROM ".. table_name .." WHERE id BETWEEN " .. range_start .. " AND " .. range_start .. "+" .. oltp_range_size - 1 .. " ORDER BY c")
   end

   end

   end
   
   if not oltp_read_only then

   for i=1, oltp_index_updates do
      rs = db_query("UPDATE " .. table_name .. " SET k=k+1 WHERE id=" .. sb_rand(1, oltp_table_size))
   end

   for i=1, oltp_non_index_updates do
      c_val = sb_rand_str("###########-###########-###########-###########-###########-###########-###########-###########-###########-###########")
      query = "UPDATE " .. table_name .. " SET c='" .. c_val .. "' WHERE id=" .. sb_rand(1, oltp_table_size)
      rs = db_query(query)
      if rs then
        print(query)
      end
   end

   for i=1, oltp_delete_inserts do

   i = sb_rand(1, oltp_table_size)

   rs = db_query("DELETE FROM " .. table_name .. " WHERE id=" .. i)
   
   c_val = sb_rand_str([[
###########-###########-###########-###########-###########-###########-###########-###########-###########-###########]])
   pad_val = sb_rand_str([[
###########-###########-###########-###########-###########]])

   rs = db_query("INSERT INTO " .. table_name ..  " (id, k, c, pad) VALUES " .. string.format("(%d, %d, '%s', '%s')",i, sb_rand(1, oltp_table_size) , c_val, pad_val))

   end

   end -- oltp_read_only

   if not oltp_skip_trx then
      db_query(commit_query)
   end

end

