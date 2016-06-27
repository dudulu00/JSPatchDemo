//main.js
//defineClass("XRTableViewController", {
//            tableView_didSelectRowAtIndexPath: function(tableView, indexPath) {
//            var row = indexPath.row()
//            if (self.dataSource().length > row) {  //加上判断越界的逻辑
//            var content = self.dataArr()[row];
//            var controller = XRViewController.alloc().initWithContent(content);
//            self.navigationController().pushViewController(controller);
//            }
//            }
//            })

// 调用require引入要使用的OC类
require('UIView, UIColor',')
        
        defineClass("ViewController", {
                    viewDidLoad: function(){
                    
                    self.view().setBackgroundColor(UIColor.greenColor());
                    console.log('这里是js脚本调用');
                    
                    
                    }
                    
                    })
        
        
        
