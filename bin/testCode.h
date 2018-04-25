/*********************************************************************
** Copyright (c) 2017 MaK Technologies, Inc.
** All rights reserved.
*********************************************************************/

class DtDynamicMapper
{
   
private:
   //not implemeneted
   DtDynamicMapper(const DtDynamicMapper& orig);
   DtDynamicMapper& operator=(const DtDynamicMapper& orig);

public:
   DtDynamicMapper();

   virtual ~DtDynamicMapper();
   
   int testValue();
   void setTestValue(const char* name, int val);
   
   template<typename T>
   T getValueAs();

protected:
   int myTestValue;

};
