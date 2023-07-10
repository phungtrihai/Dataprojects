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

Một vài câu lệnh với dữ liệu mảng:
- insert()
- pop()
- remove()
- append()

## **Part 2: Cấu trúc dữ liệu Stack & Queue**
### Cấu trúc Stack
Stack là một loại container adaptor, được thiết kế để hoạt động theo kiểu LIFO (Last - in first - out) (vào sau ra trước), tức là một kiểu danh sách mà việc bổ sung và loại bỏ một phần tử được thực hiển ở cuối danh sách. Vị trí cuối cùng của stack gọi là đỉnh (top) của ngăn xếp.



Stack giống như việc giáo viên kiểm tra vở bài tập của học sinh vậy, ai nộp sau cùng thì vở bài tập của người đó sẽ được giáo viên kiểm tra đầu tiên, đương nhiên người nộp vợ đầu tiên sẽ được kiểm tra cuối cùng.

Stack có các hàm sau (ví dụ cho C++):

size : trả về kích thước hiện tại của stack. ĐPT O(1).  
empty : true stack nếu rỗng, và ngược lại. ĐPT O(1).  
push : đẩy phần tử vào stack. ĐPT O(1).  
pop : loại bỏ phẩn tử ở đỉnh của stack. ĐPT O(1).  
top : truy cập tới phần tử ở đỉnh stack. ĐPT O(1).  

### Giới thiệu về queue:
Queue(hàng đợi) là một loại container, được thiết kế để hoạt động theo kiểu **FIFO (First- in first – out)** (vào trước ra trước), tức là một kiểu danh sách mà việc bổ sung được thực hiển ở cuối danh sách và loại bỏ ở đầu danh sách.

Trong queue, có hai vị trí quan trọng là vị trí đầu danh sách (front), nơi phần tử được lấy ra, và vị trí cuối danh sách (back), nơi phần tử cuối cùng được thêm vào.

Các phương thức (ngôn ngữ C++):

**Capacity**  
- size()	Trả về số lượng phần tử của queue  
- empty()	Trả về true(1) nếu queue rỗng, ngược lại là false (0)  

**Element access**  
- front()	Truy xuất phần tử ở đầu queue (phần tử đầu tiên được thêm vào)  
- back()	Truy xuất phần tử ở cuối queue (phần tử cuối cùng được thêm vào) 

**Modifier:**  
- push (const x)	Thêm phần tử có giá trị x vào cuối queue. Kích thước queue tăng thêm 1.
- pop ()	Loại bỏ phần tử ở đầu queue. Kích thước queue giảm đi 1.

## Part 3: Giới thiệu danh sách liên kết.
Danh sách liên kết đơn(Single linked list) là ví dụ tốt nhất và đơn giản nhất về cấu trúc dữ liệu động sử dụng con trỏ để cài đặt. Do đó, kiến thức con trỏ là rất quan trọng để hiểu cách danh sách liên kết hoạt động, vì vậy nếu bạn chưa có kiến thức về con trỏ thì bạn nên học về con trỏ trước. Bạn cũng cần hiểu một chút về cấp phát bộ nhớ động. Để đơn giản và dễ hiểu, phần nội dung cài đặt danh sách liên kết của bài này sẽ chỉ trình bày về danh sách liên kết đơn.

Danh sách liên kết đơn là một tập hợp các Node được phân bố động, được sắp xếp theo cách sao cho mỗi Node chứa một giá trị (Data) và một con trỏ (Next). Con trỏ sẽ trỏ đến phần tử kế tiếp của danh sách liên kết đó. Nếu con trỏ mà trỏ tới NULL, nghĩa là đó là phần tử cuối cùng của linked list.

So sánh mảng và danh sách liên kết:

![Alt text](https://scontent.fsgn8-2.fna.fbcdn.net/v/t1.15752-9/358902935_808596847308653_6234565586791959926_n.png?_nc_cat=111&ccb=1-7&_nc_sid=ae9488&_nc_ohc=N3Fd7MXklcYAX-WP59W&_nc_ht=scontent.fsgn8-2.fna&oh=03_AdQDdn5QSF2bFSXA8s-5lTK8uBIgbc-levmmQiLHP9aYQw&oe=64D2282E)

**Cách loại danh sách liên kết:**

Danh sách liên kết đơn- Linked List.  
Danh sách liên kết đôi - Doubly Linked List.  
Danh sách liên kết vòng - Circular Linked List. 

## Part 4: What is a tree data structure?
> The tree data structure represents the nodes 

A binary tree is a special data structure used for data storage purposes. A binary tree has a special condition that each node can have up to **two child nodes**. A binary tree takes advantage of two types of data structures: an ordered array and a linked list, so that searches are as fast as in sorted arrays and operations. Insertion and deletion will also be as fast as in Linked List.

### Basic concepts of binary trees
Here are some important concepts related to binary trees:

- Road: is a sequence of nodes along with the edges of a tree.  
- Root: The top node of the tree is called the root node. A tree will have only one root node and one path from the root to any other node. The root node is the only node that does not have any parent nodes.

- Parent node: any node except the root node that has an edge pointing up another node is called a parent node.

- Child Node: The node below a given node connected by its bottom edge is called the child node of that node.

- Leaf node: A node without any child nodes is called a leaf node.

- Subtree: The subtree represents the children of a node.

- Access: checks the value of a node when the control is on that node.

- Traversal: traverse the nodes in some order.

- Degree: The degree of a node represents the number of children of a node. If the root node has degree 0, then the next child node will have degree 1, and its grandchild node will have degree 2, etc.

- Key: represents a value of a node based on what a search operation does on the node.