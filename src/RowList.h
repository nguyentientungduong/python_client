/*
    Copyright (c) 2017 TOSHIBA Digital Solutions Corporation.
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
        http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

#ifndef _ROWLIST_H_
#define _ROWLIST_H_

#include "gridstore.h"

namespace griddb {
class RowList {
 private:
    GSRowSet *mRowSet;
    GSRow *mRow;
    GSType* mTypelist;
    int mColumnCount;
    bool mTimetampFloat;
 public:
    RowList(GSRow *gsRow, GSRowSet *gsRowSet, GSType* typelist, int columnCount,
            bool timetampFloat);
    void __next__(bool* hasRow);
    RowList* __iter__();
    GSRow* get_gsrow_ptr();
    GSType* get_gstype_list();
    int get_column_count();
    bool get_timestamp_to_float();
};
}  // namespace griddb

#endif  // _ROWLIST_H_
