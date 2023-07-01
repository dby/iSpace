//
// Created by 陈秋文 on 2022/11/10.
//

/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import WCDB_Private

public final class IndexConfig<CodingTableKeyType: CodingTableKey>: TableConfiguration {
    private let indexes: [IndexedColumnConvertible]
    private let subfix: String
    private let unique: Bool

    public func config(with tableBinding: TableBindingBase) {
        let statement = StatementCreateIndex().ifNotExists().indexesBy(indexes)
        if unique {
            statement.unique()
        }
        withExtendedLifetime(statement) {
            WCDBBindingAddIndex(tableBinding.cppBinding, subfix.cString, $0.cppObj)
        }
    }

    required public init(_ indexes: IndexedColumnConvertible..., namedWith subfix: String, isUnique: Bool = false) {
        self.subfix = subfix
        self.indexes = indexes
        unique = isUnique
    }
}
