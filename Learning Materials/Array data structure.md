## **Part 1: Cấu trúc dữ liệu mảng (Array)**

### **Lý thuyết.**

#### **Cấu trúc dữ liệu mảng là gì ?**

Mảng (Array) là một trong các cấu trúc dữ liệu cũ và quan trọng nhất. Mảng có thể lưu giữ một số phần tử cố định và các phần tử này **nên có cùng kiểu**. Hầu hết các cấu trúc dữ liệu đều sử dụng mảng để triển khai giải thuật. Dưới đây là các khái niệm quan trọng liên quan tới Mảng.

- **Phần tử:** Mỗi mục được lưu giữ trong một mảng được gọi là một phần tử.

- **Chỉ mục (Index)**: Mỗi vị trí của một phần tử trong một mảng có một chỉ mục số được sử dụng để **nhận diện phần tử**.

Mảng gồm các bản ghi có kiểu giống nhau, có kích thước cố định, mỗi phần tử được xác định bởi chỉ số.

Mảng là cấu trúc dữ liệu được cấp phát liên tục cơ bản.

Ưu điểm của mảng :

- Truy câp phần tử vơi thời gian hằng số O(1). (thời gian truy cập phần tử không phụ thuộc vào kích thước mảng)
- Sử dụng bộ nhớ hiệu quả.
- Tính cục bộ về bộ nhớ.

Nhược điểm của mảng:

- Không thể thay đổi kích thước của mảng khi chương trình dang thực hiện.

**Mảng động:**

**Mảng động (dynamic aray)** : cấp phát bộ nhớ cho mảng một cách động trong quá trình chạy chương trình trong C là malloc và calloc, trong C++ là new.

Sử dụng mảng động ta bắt đầu với mảng có 1 phần tử, khi số lượng phần tử vượt qua khả năng của mảng thì ta gấp đôi kích thước mảng cũ và copy phần tử mảng cũ vào nửa đầu của mảng mới.

Ưu điểm:

Tránh lãng phí bộ nhớ khi phải khai báo mảng có kích thước lớn ngay từ đầu.

Nhược điểm:

Phải thực hiện them thao tác copy phần tử mỗi khi thay đổi kích thước.
Một số thời gian thực hiện thao tác không còn là hằng số nữa.

#### **Biểu diễn Cấu trúc dữ liệu mảng.**
Mảng có thể được khai báo theo nhiều cách đa dạng trong các ngôn ngữ lập trình. Để minh họa, chúng ta sử dụng phép khai báo mảng trong ngôn ngữ C:

![Alt text](https://scontent.fsgn7-1.fna.fbcdn.net/v/t1.15752-9/356571584_789495896001888_3856023436565554870_n.png?_nc_cat=108&ccb=1-7&_nc_sid=ae9488&_nc_ohc=-rFOkz5jv-UAX_bLtMe&_nc_ht=scontent.fsgn7-1.fna&oh=03_AdRllBT_dSwoyu_cmttJS7M9ndBlocC8FvXMYZuAQssOrQ&oe=64BFC922)

Hình minh họa phần tử và chỉ số:
![Alt text](https://scontent.fsgn7-1.fna.fbcdn.net/v/t1.15752-9/356565328_825486278674482_3740235138588897104_n.png?_nc_cat=107&ccb=1-7&_nc_sid=ae9488&_nc_ohc=UdGF_dhje2YAX8JJtDm&_nc_ht=scontent.fsgn7-1.fna&oh=03_AdQx4Fs_1hdFIREuGyS0lIG8Re-8HJrj_bCGtpSrR-mtdw&oe=64BFECD3)



Dưới đây là một số điểm cần ghi nhớ về cấu trúc dữ liệu mảng:

- Chỉ mục bắt đầu với `0`.

- Độ dài mảng là `5`, nghĩa là mảng có thể lưu giữ `5` phần tử.

- Mỗi phần tử đều có thể được truy cập thông qua chỉ số của phần tử đó. Ví dụ, chúng ta có thể lấy giá trị của phần tử tại chỉ số `3` là `-9`.

Một vài câu lệnh với dữ liệu mảnh:
- insert()
- pop()
- remove()
- append()



a= []
n = int(input())
for i in range(n):
    a.append((int)(input()))




result = ' '.join(map(str, a))

print(result)