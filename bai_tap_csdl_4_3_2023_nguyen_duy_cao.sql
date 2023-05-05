alter table SINH_VIEN_2
add [ghi chú] nvarchar(50),
    [giới tính] nvarchar(10);

select Masosv,ten,hodem,hocluc ,case  [giới tính ]  when 1 then 'nam' else 'nu'
end as [giới tính ] from SINH_VIEN_2

select tendetai,sotinchi, sotinchi * 15 as [số tiết ] from DETAI_1
--Hiển thị 10% số lượng danh sách đề tài có trong bảng đề tài
--Kiem tra noi thuc tap co ma de tai 05
--Đưa ra tên gần đúng của những sinh viên có chữ cái đầu là H_a
--Đưa ra thông tin sv có họ tr tên tha
--ĐƯA RA Msdt, TENDT, KINH PHI CỦA NHỮNG ĐỀ TÀI CÓ KP TỪ 1 ĐẾN 5
--CHO THÔNG TIN VỀ NHỮNG SINH VIÊN HỌC LỰC KHÔNG NẰM TRONG KHOẢNG 6.5 ĐẾN 7.0
--dua ra danh sach ca sinh vien tre duoi 18 tuoi và HL>8.0
--dua ra thong tin ve nhung de ta duoc cap kinh phí tren 5tr

select noithuctap from  SINHVIEN_DETAI where Masodetai = 'sv19'

select * from SINH_VIEN_2 where ten LIKE 'T%n'

select * from SINH_VIEN_2 where hodem LIKE 'Ma%' and ten like 'd%'


select * from SINH_VIEN_2 where hocluc > 8.0


