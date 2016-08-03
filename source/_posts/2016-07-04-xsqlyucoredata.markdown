---

layout: post
title: "CoreData 大战 SQLite"
date: 2016-07-05 14:59:42 +0800
comments: true
categories: Senior
description: iCocos博客
keywords: iCocos, iOS开发, 博客, 技术分析, 文章, 学习, 曹黎, 曹理鹏

---


凭良心讲，我不能告诉你不去使用Core Data。它不错，而且也在变好，并且它被很多其他Cocoa开发者所理解，当有新人加入你的组或者需要别人接手你的项目的时候，这点很重要。

 
更重要的是，不值得花时间和精力去写自己的系统去代替它。真的，使用Core Data吧。
 
为什么我不使用Core Data  
 Mike Ash写到：就我自己而言，我不是个狂热粉丝。我发现API是笨拙的，并且框架本身对于大量的数据是极其缓慢的。
 
一个实际的例子：10,000条目
想象一个RSS阅读器，一个用户可以在一个feed上点击右键，并且选择标记所有为已读。
 


<!--more-->



引擎下，有一个带有read属性的Article实体。把所有条目标记为已读，程序需要加载这个feed的所有文章(可能通过一对多的关系)，然后设置read属性为YES。
 
大部分情况下这样没关系。但是设想那个feed里有200个文章，为了避免阻塞主线程，你可能考虑在后台线程里做这个工作(特别当你的程序是一个iPhone应用)。当你一开始使用Core Data多线程，事情就开始变的不好处理了。
 
这可能还凑合，至少不值得切换走Core Data。
 
但是接下来加同步。
 
我用过两种不同的获取已读文章ID列表的RSS同步接口。其中一个返回近10,000个ID。
 
你不会打算在主线程中加载10,000个文章，然后设置read为NO。你甚至不想在后台线程里加载10,000个文章，即使很小心的管理内存，这有太多的工作（如果你频繁的这么做，想一下对电池寿命的影响）。
 
你真正想要做的是，让数据库给在ID列表里的每一个文章设置read为YES。
 
SQLite可以做到这个，只用一次调用。假设uniqueID上有索引，这会很快。而且你可以在后台线程执行像在主线程执行一样容易。
 
另一个例子：快速启动
我想减少我的另一个程序的启动时间，不只是开始的时间，而是在数据显示之前的所有时间。
 
那是个类似Twitter的应用(虽然它不是)，它显示消息的时间轴。显示时间轴意味着获取消息，加载相关用户。它很快，但是在启动的时候，会填充UI，然后填充数据。
 
关于iPhone的应用（或者所有应用）我的理论是，启动时间很重要，比其他大部分开发者想的都要重要。应用的启动很慢看起来不像是要启动一样，因为人们潜意识里记得，并且会产生阻止启动应用的想法。减少启动时间就减少了摩擦，让用户更有可能继续使用你的应用，并且推荐给其他人。这是你让你的应用成功的一部分。
 
因为我不使用Core Data，我手边有一个简单的，保守的解决方案。我把timeline（消息和人物对象）通过NSCoding保存到一个plist文件中。启动的时候它读这个文件，创建消息和人物对象，UI一出现就显示时间轴。
 
这明显的减少了延迟。
 
把消息和人物对象作为NSManagedObject的实例对象，这是不可能的。（假设我有编码的并且存储的IDs对象，但是那意味着读plist然后触及数据库。这种方式我完全避免了数据库）。
 
在更新更快的机器出来后, 我去掉了那些代码。回顾过去，我希望我可以把它留下来。
 
我怎么考虑这个问题
当考虑是否使用Core Data时，我考虑下面这些事情：
 
会有难以置信数量的数据吗？
对于一个RSS阅读器或者Twitter应用，答案显而易见：是的。有些人关注上百个人。一个人可能订阅了上千个feeds。
 
即使你的应用不从网络获取数据，仍然有可能让用户自动添加数据。如果你用一个支持AppleScript的Mac，有些人会写脚本去加载非常多的数据。如果通过web API去加数据也是一样的。
 
会有一个Web API包含类似于数据库的终端吗（对比类对象终端）？
一个RSS同步API能够返回一个已读文章的uniquelIDs列表。一个记笔记的应用的一个同步API可能返回已存档的和已删除的笔记的uniquelIDs。
 
用户可能通过操作处理大量对象吗？
在底层，需要考虑和之前一样的问题。当有人删除所有下载的5，000个面食食谱，你的食谱应用可以多好的完成这个功能（在iPhone上？）？
 
当我决定使用Core Data（我已经发布过使用Core Data的应用），我会小心留意我怎么使用它。为了得到好的性能，我发现我把它当做一个SQL数据库的一个奇怪接口来使用，然后我知道我应该舍弃Core Data，直接使用SQLite。
 
我怎么使用SQLite
我通过FMDB Wrapper来使用SQLite，FMDB来自Flying Meat Software，由Gus Mueller提供。
 
基本操作
我在iPhone以前，Core Data以前就使用过SQLite。这是它怎么工作的的要点：

1. 所有数据库访问-读和写-发生在连续的队列里，在一个后台线程。在主线程中触及数据库是从来不被允许的。使用一个连续队列来保证每一件事是按顺序发生的。
2. 我大量使用blocks来让异步程序容易点。
3. 模型对象只存在在主线程（但有两个重要的例外），改变会触发一个后台保存。
4. 模型对象列出来他们在数据库中存储的属性。可能在代码里或者在plist文件里。
5, 一些模型对象是唯一的，一些不是。取决于应用的需要（大部分情况是唯一的）。
6. 对关系型数据，我尽可能避免连表查询。
7. 一些对象类型在启动的时候就完全读入内存，另一些对象类型可能只需要创建并维护一个他们的uniqueIDs的。NSMutableSet，所以不需要去触及数据库，我就知道已经有什么。
8. Web API的调用发生在后台线程，他们使用分开的模型对象。
我会通过我现在的应用的代码来详细描述。
 
数据库更新
在我最近的应用中，有一个单一的数据库控制器-VSDatabaseController，它通过FMDB来与SQLite对话。
 
FMDB区分更新和查询。更新数据库，app调用：

    -[VSDatabaseController runDatabaseBlockInTransaction:(VSDatabaseUpdateBlock)databaseBlock] 

 
VSDatabaseUpdateBlock很简单：

    typedef void (^VSDatabaseUpdateBlock)(FMDatabase *database); 

 
runDatabaseBlockInTransaction也很简单：

    - (void)runDatabaseBlockInTransaction:(VSDatabaseUpdateBlock)databaseBlock { 
        dispatch_async(self.serialDispatchQueue, ^{ 
            @autoreleasepool { 
                [self beginTransaction]; 
                databaseBlock(self.database); 
                [self endTransaction]; 
            } 
        }); 
    } 

（注意我用自己的连续调度队列。Gus建议看一下FMDatabaseQueue，也是一个连续调度队列。我还没能去看一下，因为它比FMDB的其他东西都要新。）
 
beginTransaction和endTransaction的调用是可嵌套的（在我的数据库控制器里）。在合适的时候他们会调用-[FMDatabase beginTransaction] 和 -[FMDatabase commit]。（使用事务是让SQLite变快的关键。）提示：我把当前事务存储在-[NSThread threadDictionary]。它很好获取每一个线程的数据，我几乎从不用其他的。
 
这儿有个调用更新数据库的简单例子：

    - (void)emptyTagsLookupTableForNote:(VSNote *)note { 
        NSString *uniqueID = note.uniqueID; 
        [self runDatabaseBlockInTransaction:^(FMDatabase *database) { 
            [database executeUpdate: 
                @"delete from tagsNotesLookup where noteUniqueID = ?;", uniqueID]; 
        }]; 
    } 

 
这说明一些事情。首先SQL不可怕。即使你从没见过它，你也知道这行代码做了什么。
 
像VSDatabaseController的所有其他公共接口，emptyTagsLookupTableForNote应该在主线程中被调用。模型对象只能在主线程中被引用，所以在block中用uniqueID，而不是VSNote对象。
 
注意在这种情况下，我更新了一个查找表。Notes和tags是多对多关系，一种表现方式是用一个数据库表映射note uniqueIDs和tag uniqueIDs。这些表不会很难维护，但是如果可能，我确实尝试避免他们的使用。
 
注意在更新字符串中的?。-[FMDatabase executeUpdate:] 是一个可变参数函数。SQLite支持使用占位符?，所以你不需要把正真的值放入字符串。这儿有一个安全问题：它帮助守护程序反对SQL插入。如果你需要避开某些值，它也为你省了麻烦。
 
最后，在tagsNotesLookup表中，有一个noteUniquelID的索引（索引是SQLite性能的又一个关键）。这行代码在每次启动时都调用：

    [self.database executeUpdate: 
        @"CREATE INDEX if not exists noteUniqueIDIndex on tagsNotesLookup (noteUniqueID);"]; 

 
数据库获取
要获取对象，app调用：

    -[VSDatabaseController runFetchForClass:(Class)databaseObjectClass  
                                 fetchBlock:(VSDatabaseFetchBlock)fetchBlock  
                          fetchResultsBlock:(VSDatabaseFetchResultsBlock)fetchResultsBlock]; 

 
这两行代码做了大部分工作：

    FMResultSet *resultSet = fetchBlock(self.database); 
    NSArray *fetchedObjects = [self databaseObjectsWithResultSet:resultSet  
                                                           class:databaseObjectClass]; 

 
用FMDB查找数据库返回一个FMResultSet. 通过resultSet你可以逐句循环，创建模型对象。
 
我建议写通用的代码去转换数据库行到对象。一种我使用的方法是用一个plist，映射column名字到对象属性。它也包含类型，所以你知道是否需要调用 -[FMResultSet dateForColumn:]， -[FMResultSet stringForColumn:]或其他。
 
在我的最新应用里我做了些简单的事情。数据库行刚好对应模型对象属性的名字。所有属性都是strings，除了那些名字以“Date”结尾的属性。很简单，但是你可以看到需要一个清晰的对应关系。
 
唯一对象
创建模型对象和从数据库获取数据在同一个后台线程。一获取到，程序会把他们转到主线程。
 
通常我有uniqued对象。同一个数据库行结果始终对应同一个对象。
 
为了做到唯一，我创建了一个对象缓存，一个NSMapTable，在init函数里：_objectCache = [NSMapTable weakToWeakObjectsMapTable]。我来解释一下：
 
例如，当你做一个数据库获取并且把对象转交给一个视图控制器，你希望在视图控制器使用完这些对象后，或者一个不一样的视图控制器显示了，这些对象可以消失。
 
如果你的对象缓存是一个NSMutableDictionary，你将需要做一些额外的工作来清空缓存中的对象。确定它对应的对象在别的地方是否有引用就变的很痛苦。NSMapTable是弱引用，就会自动处理这个问题。
 
所以：我们在主线程中让对象唯一。如果一个对象已经在对象缓存中存在，我们就用那个存在的对象。（主线程胜出，因为它可能有新的改变。）如果对象缓存中没有，它会被加上。
 
保持对象在内存中
有很多次，把整个对象类型保留在内存中是有道理的。我最新的app有一个VSTag对象。虽然可能有成百上千个笔记，但tags的数量很小，基本少于10。一个tag只有6个属性：3个BOOL，两个很小的NSstring，还有一个NSDate。
 
启动的时候，app获取所有tags并且把他们保存在两个字典里，一个主键是tag的uniqueID，另一个主键是tag名字的小写。
 
这简化了很多事，不只是tag自动补全系统，这个可以完全在内存中操作，不需要数据库获取。
 
但是很多次，把所有数据保留在内存中是不实际的。比如我们不会在内存中保留所有笔记。
 
但是也有很多次，当不能在内存中保留对象时，你希望在内存中保留所有uniqueIDs。你会像这样做一个获取：

    FMResultSet *resultSet = [self.database executeQuery:@"select uniqueID from some_table"]; 

resultSet只包含了uniqueIDs， 你可以存储到一个NSMutableSet里。
 
我发现有时这个对web APIs很有用。想象一个API调用返回从某个确定的时间以后的，已创建笔记的uniqueIDs列表。如果我本地已经有了一个包含所有笔记uniqueIDs的NSMutableSet，我可以快速检查(通过 -[NSMutableSet minusSet])是否有漏掉的笔记，然后去调用另一个API下载那些漏掉的笔记。这些完全不需要触及数据库。
 
但是，像这样的事情应该小心处理。app可以提供足够的内存吗？它真的简化编程并且提高性能了吗？
 
用SQLite和FMDB而不是Core Data，给你带来大量的灵活性和聪明解决办法的空间。记住有的时候聪明是好的，也有的时候聪明是一个大错误。
 
Web APIs
我的API调用在后台进程（经常用一个NSOperationQueue，所以我可以取消操作）。模型对象只在主线程，但是我还传递模型对象给我的API调用。
 
是这样的：一个数据库对象有一个detachedCopy方法，可以复制数据库对象。这个复制对象不是引用自我用来唯一化的对象缓存。唯一引用那个对象的地方是API调用，当API调用结束，那个复制的对象就消失了。
 
这是一个好的系统，因为它意味着我可以在API调用里使用模型对象。方法看起来像这样：

    - (void)uploadNote:(VSNote *)note { 
        VSNoteAPICall *apiCall = [[VSNoteAPICall alloc] initWithNote:[note detachedCopy]]; 
        [self enqueueAPICall:apiCall]; 
    } 

VSNoteAPICall从复制的VSNote获取值，并且创建HTTP请求，而不是一个字典或其他笔记的表现形式。
 
处理Web API返回值
我对web返回值做了一些类似的事情。我会对返回的JSON或者XML创建一个模型对象，这个模型对象也是分离的。它不是存储在为了唯一性的模型缓存里。
 
这儿有些事情是不确定的。有时有必要用那个模型对象在两个地方做本地修改：在内存缓存和数据库。
 
数据库通常是容易的部分。比如：我的应用已经有一个方法来保存笔记对象。它用一个SQL insert或者replace字符串。我只需调用那个从web API返回值生成的笔记对象，数据库就会更新。
 
但是可能那个对象有一个在内存中的版本，幸运的是我们很容易找到：

    VSNote *cachedNote = [self.mapTable objectForKey:downloadedNote.uniqueID]; 

 
如果cachedNote存在，我会让它从downloadedNote中获取值，而不是替换它（这样可能违反唯一性）。这可以共享detachedCopy方法的代码。
 
一旦cachedNote更新了，观察者会通过KVO通知笔记，或者我会发送一个NSNotification，或者两者都做。
 
Web API调用也会返回一些其他值。我提到过RSS阅读器可能获得一个已读条目的大列表。这种情况下，我用那个列表创建了一个NSSet，在内存中更新每一个缓存文章的read属性，然后调用-[FMDatabase executeUpdate:]。
 
让它工作快速的关键是NSMapTable的查找是快速的。如果你找的对象在一个NSArray里，我们该重新考虑。
 
数据库迁移
Core Data的数据库迁移很酷，当它可行的时候。但是不可避免的，它是代码和数据库中的一层。如果你越直接使用SQLite，你更新数据库越直接。你可以安全容易的做到这点。
 
比如加一个表：

    [self.database executeUpdate:@"CREATE TABLE if not exists tags " 
        "(uniqueID TEXT UNIQUE, name TEXT, deleted INTEGER, deletedModificationDate DATE);"]; 

 
或者加一个索引：

    [self.database executeUpdate:@"CREATE INDEX if not exists " 
        "archivedSortDateIndex on notes (archived, sortDate);"]; 

 
或者加一列：

    [self.database executeUpdate:@"ALTER TABLE tags ADD deletedDate DATE"]; 

 
应用应该在代码的第一个地方用上面这些代码设置数据库。以后的改变只需加executeUpdate的调用 — 我让他们按顺序执行。因为我的数据库是我设计的，不会有什么问题（我从没碰到性能问题，它很快）。
 
当然大的改变需要更多代码。如果你的数据通过web获取，有时你可以从一个新数据库模型开始，重新下载你需要的数据。
 
性能技巧
SQLite可以非常非常快，它也可以非常慢。完全取决于你怎么使用它。
 
事务
把更新包装在事务里。在更新前调用 -[FMDatabase beginTransaction] ，更新后调用-[FMDatabase commit]。
 
如果你不得不反规范化（ Denormalize）
反规范化让人很不爽。这个方法是，为了加速检索而添加冗余数据，但是它意味着你需要维护冗余数据。
 
我总是疯狂避免它，直到这样能有严重的性能区别。然后我会尽可能少得这么做。
 
使用索引
我的应用中tags表的创建语句像这样：

    CREATE TABLE if not exists tags  
      (uniqueID TEXT UNIQUE, name TEXT, deleted INTEGER, deletedModificationDate DATE); 

 
uniqueID列是自动索引的，因为它定义为unique。但是如果我想用name来查询表，我可能会在name上创建一个索引，像这样：

    CREATE INDEX if not exists tagNameIndex on tags (name); 

 
你可以一次性在多列上创建索引，像这样：

    CREATE INDEX if not exists archivedSortDateIndex on notes (archived, sortDate); 

 
但是注意太多索引会降低你的插入速度。你只需要足够数量并且是对的那些。
 
使用命令行应用
当我的app在模拟器里运行时，我会打印数据库的路径。我可以通过sqlite3的命令行来打开数据库。（通过man sqlite3命令来了解这个应用的更多信息）。
 
打开数据库的命令：sqlite3 “数据库的路径”。
 
打开以后，你可以看schema: type .schema。
 
你可以更新和查询，这是在使用你的app之前检查SQL是否正确的很好的方式。
 
这里面最酷的一部分是，SQLite Explain Query Plan命令，你会希望确保你的语句执行的尽可能快。
 
真实的例子
我的应用显示所有没有归档笔记的标签列表。每当笔记或者标签有变化，这个查询就会重新执行一次，所以它需要很快。
 
我可以用SQL join来查询，但是很慢（joins都很慢）。
 
所以我放弃sqlite3并开始尝试别的方法。我又看了一次我的schema，意识到我可以反规范化。一个笔记的归档状态可以存储在notes表里，它也可以存储在tagsNotesLookup表。
 
然后我可以执行一个查询：

    select distinct tagUniqueID from tagsNotesLookup where archived=0; 

 
我已经有了一个在tagUniqueID上的索引。所以我用explain query plan来告诉我当我执行这个查询的时候会发生什么。

    sqlite> explain query plan select distinct tagUniqueID from tagsNotesLookup where archived=0; 
    0|0|0|SCAN TABLE tagsNotesLookup USING INDEX tagUniqueIDIndex (~100000 rows) 

 
它用了一个索引，但是SCAN TABLE听起来不太好，最好是一个SEARCH TABLE并且覆盖一个索引。
我在tagUniqueID和archive上建了索引：

    CREATE INDEX archivedTagUniqueID on tagsNotesLookup(archived, tagUniqueID); 

 
再次执行explain query plan:

    sqlite> explain query plan select distinct tagUniqueID from tagsNotesLookup where archived=0; 
    0|0|0|SEARCH TABLE tagsNotesLookup USING COVERING INDEX archivedTagUniqueID (archived=?) (~10 rows) 

好多了。
 
更多性能提示
FMDB的某处加了缓存statements的能力，所以当创建或打开一个数据库的时候，我总是调用[self.database setShouldCacheStatements:YES] 。这意味着对每个调用你不需要再次编译每个statement。
 
我从来没有找到使用vacuum的好的指引，如果数据库没有定期压缩，它会越来越慢。我的应用会跑一个vacuum，但只是每周一次（它在NSUserDefaults里存储上次vacuum的时间，然后在开始的时候检查是否过了一周）。
 
如果能auto_vacuum那更好，看pragma statements supported by SQLite列表。 
 
其他酷的东西
Gus Mueller让我涉及自定义SQLite方法的内容。我并没有真的使用这些东西，既然他指出了，我可以放心的说我能找到它的用处。因为它很酷。
 
在Gus的帖子里，有一个查询是这样的：

    select displayName, key from items where UTTypeConformsTo(uti, ?) order by 2; 

 
SQLite完全不知道UITypes。但是你可以加核心方法，查看-[FMDatabase makeFunctionNamed:maximumArguments:withBlock:]。
 
你可以执行一个大的查询来替代，然后评估每个对象。但是那需要更多工作。最好在SQL级就过滤，而不是在将表格行转为对象以后。
 
最后
你真的应该使用Core Data，我不是在开玩笑。
 
我用SQLite和FMDB一段时间了，我对多得的好处感到很兴奋，也得到非同一般的性能。但是记住机器在变快，其他看你代码的人期望看到他已经知道的Core Data, 另一些不打算看你的数据库代码。所以请把这整篇文章看做一个疯子的叫喊，关于他为自己建立的细节的疯狂的世界，并把自己锁在里面。
 
请享受了不起的Core Data的文章（有点难过的摇头）。
 
接下来，在查完Gus指出的自定义SQLite方法特性后，我会研究SQLite的full-text search extension. 总有更多的内容需要去学习。
