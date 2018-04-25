// Singleton 
class CSingleton {  
private:  
	CSingleton() {}  
	static CSingleton *m_pInstance;  
	class CGarbo {  
		//它的唯一工作就是在析构函数中删除CSingleton的实例  
		public:  
			~CGarbo() {  
				if(CSingleton::m_pInstance)  
					delete CSingleton::m_pInstance;  
			}  
	}; 
	static CGarbo Garbo;  //定义一个静态成员变量，程序结束时。系统会自己主动调用它的析构函数  
public:  
	static CSingleton * GetInstance() {  
		if(m_pInstance == NULL)  //推断是否第一次调用  
			m_pInstance = new CSingleton();  
		return m_pInstance;  
	} 
};
